const cds = require('@sap/cds');
require('dotenv').config();

module.exports = class LogaliGroup extends cds.ApplicationService {

    async init() {

        const { Products, Inventories, CBusinessPartner, CSuppliers, CCustomer } = this.entities;
        const cloud = await cds.connect.to("API_BUSINESS_PARTNER");
        const onpremise = await cds.connect.to("API_BUSINESS_PARTNER_CLUD");

        const { CartItem } = this.entities;


        this.on('addToCart', 'Products', async (req) => {
            // default en backend
            const qty = Math.max(1, Number(req.data.quantity ?? 1));
            const user = (req.user && req.user.id) || 'anonymous';

            const productID = req.params?.[0]?.ID;
            if (!productID) return req.reject(400, 'Producto no válido');

            const existing = await SELECT.one.from(CartItem).where({
                'product_ID': productID, user, status: 'OPEN'
            });

            if (existing) {
                await UPDATE(CartItem, existing.ID).with({ quantity: { '+=': qty } });
                return SELECT.one.from(CartItem).where({ ID: existing.ID });
            }

            const inserted = await INSERT.into(CartItem).entries({
                product_ID: productID,
                quantity: qty,
                user,
                status: 'OPEN'
            });

            return SELECT.one.from(CartItem).where({ ID: inserted.ID });
        });

        // Aumentar cantidad
        this.on('Increase', 'Cart', async (req) => {
            const by = Math.max(1, Number(req.data.by ?? 1));
            const cartRowId = req.params?.[0]?.ID;
            if (!cartRowId) return req.reject(400, 'Fila inválida');

            await UPDATE(CartItem, cartRowId).with({ quantity: { '+=': by } });
            return 1;
        });

        // Disminuir cantidad (si llega a 0, se elimina)
        this.on('Decrease', 'Cart', async (req) => {
            const by = Math.max(1, Number(req.data.by ?? 1));
            const cartRowId = req.params?.[0]?.ID;
            if (!cartRowId) return req.reject(400, 'Fila inválida');

            const row = await SELECT.one.from(CartItem).where({ ID: cartRowId });
            if (!row) return 0;

            const newQty = (row.quantity || 1) - by;
            if (newQty > 0) {
                await UPDATE(CartItem, cartRowId).with({ quantity: newQty });
            } else {
                await DELETE.from(CartItem).where({ ID: cartRowId });
            }
            return 1;
        });

        // Eliminar item del carrito
        this.on('RemoveFromCart', async (req) => {
            const { ID } = req.data;
            if (!ID) return req.reject(400, 'Missing ID');

            // Si filtras por usuario/estado en READ, replica aquí para seguridad:
            const user = req.user?.id || 'anonymous';
            // Quita `status:'OPEN'` si no lo usas
            const affected = await DELETE.from(CartItem).where({ ID, user /*, status: 'OPEN'*/ });

            if (!affected) return req.reject(404, 'Item not found');
            return true;
        });

        // Vaciar carrito del usuario actual con status OPEN
        this.on('EmptyCart', async (req) => {
            const user = (req.user && req.user.id) || 'anonymous';
            const { affectedRows } = await DELETE.from(CartItem).where({ user, status: 'OPEN' });
            return affectedRows ?? 0;
        });

        // Checkout = marcar como ORDERED
        this.on('Checkout', async (req) => {
            const user = (req.user && req.user.id) || 'anonymous';
            const { affectedRows } = await UPDATE(CartItem)
                .set({ status: 'ORDERED' })
                .where({ user, status: 'OPEN' });
            return affectedRows ?? 0;
        });

        //cloud.run(UPDATE(CBusinessPartner));

        this.on('READ', CCustomer, async (req) => {
            return await cloud.tx(req).send({
                query: req.query,
                headers: {
                    apikey: process.env.APIKEY
                }
            })
        });

        this.on('READ', CBusinessPartner, async (req) => {
            return await cloud.tx(req).send({
                query: req.query,
                headers: {
                    apikey: process.env.APIKEY
                }
            })
        });

        this.on('READ', CSuppliers, async (req) => {

            return await cloud.tx(req).send({
                query: req.query,
                headers: {
                    apikey: process.env.APIKEY
                }
            })
        });

        this.before('NEW', Products.drafts, async (req) => {
            req.data.detail ??= {
                baseUnit: 'EA',
                width: null,
                height: null,
                depth: null,
                weight: null,
                unitVolume: 'CM',
                unitWeight: 'KG'
            }
        });

        this.before('NEW', Inventories.drafts, async (req) => {

            let result = await SELECT.one.from(Inventories).columns('max(stockNumber) as max');
            let result2 = await SELECT.one.from(Inventories.drafts).columns('max(stockNumber) as max').where({ product_ID: req.data.product_ID });

            let max = parseInt(result.max);
            let max2 = parseInt(result2.max);
            let newMax = 0;

            if (isNaN(max2)) {
                newMax = max + 1;
            } else if (max < max2) {
                newMax = max2 + 1;
            } else {
                newMax = max + 1;
            }

            req.data.stockNumber = newMax.toString();
        });

        this.on('setStock', async (req) => {
            const productId = req.params[0].ID;
            const inventoryId = req.params[1].ID;

            const amount = await SELECT.one.from(Inventories).columns('quantity').where({ ID: inventoryId });
            let newAmount = 0;

            if (req.data.option === 'A') {
                console.log("Estoy dentro");
                newAmount = amount.quantity + req.data.amount;
                if (newAmount > 100) {
                    await UPDATE(Products).set({ statu_code: 'InStock' }).where({ ID: productId });
                }

                await UPDATE(Inventories).set({ quantity: newAmount }).where({ ID: inventoryId });

                return req.info(200, `The amount ${req.data.amount} has benn added to the inventory`);
            } else if (req.data.amount > amount.quantity) {
                return req.error(400, `There is no availability for the requested quantity`);
            } else {
                newAmount = amount.quantity - req.data.amount;

                if (newAmount > 0 && newAmount <= 100) {
                    await UPDATE(Products).set({ statu_code: 'LowAvailability' }).where({ ID: productId });
                } else if (newAmount === 0) {
                    await UPDATE(Products).set({ statu_code: 'OutOfStock' }).where({ ID: productId });
                }

                await UPDATE(Inventories).set({ quantity: newAmount }).where({ ID: inventoryId });
                return req.info(200, `The amount ${req.data.amount} has benn removed form the inventory`);
            }

        });

        this.on('Remove', async (req) => {
            const { ID } = req.data;
            const user = req.user?.id || 'anonymous';

            // elimina el item del carrito del usuario (ajusta el nombre real de la tabla)
            await DELETE.from('com.taller.CartItem')
                .where({ ID, user });

            return true;
        });

        this.on('GetCartCount', async req => {
            const { CartItem } = this.entities;
            const user = req.user?.id || 'anonymous';
            // si usas status OPEN, deja el filtro; si no, quítalo
            const row = await SELECT.one`sum(quantity) as cnt`.from(CartItem).where({ user, status: 'OPEN' });
            return row?.cnt || 0;           // CAP devolverá { "value": <n> }
        });

        return super.init();
    }

}