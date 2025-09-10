sap.ui.define([
  "sap/ui/core/mvc/ControllerExtension",
  "sap/ui/core/Fragment",
  "sap/m/Button",
  "sap/m/ObjectListItem",
  "sap/m/ObjectAttribute",
  "sap/ui/model/json/JSONModel",
  "sap/m/Text",
  "sap/m/OverflowToolbarLayoutData"
], function (
  ControllerExtension, Fragment, Button, ObjectListItem, ObjectAttribute,
  JSONModel, Text, OverflowToolbarLayoutData
) {
  "use strict";

  // util
  const wait = (ms) => new Promise(r => setTimeout(r, ms));

  // glifos que usa UI5 para el icono "carrito".
  // El que confirmaste en el DOM es "". Si ves otro, añádelo al array.
  const CART_GLYPHS = [""];

  return ControllerExtension.extend("taller.project1.ext.ProductsExt", {
    _oDialog: null,
    _btnAdded: false,
    _cartState: null,

    // control del hook DOM
    __domHookInstalled: false,
    __onDocClick: null,
    __burstTimer: null,

    /* ============================================================
     *  Ciclo de vida
     * ========================================================== */
    override: {
      onAfterRendering: function () {
        const oView = this.base.getView();

        // Modelo para el badge (una sola vez)
        if (!this._cartState) {
          this._cartState = new JSONModel({ cartCount: 0 });
          oView.setModel(this._cartState, "cart");
          this._syncBadge(); // lectura inicial
        }

        // Botón "ver carrito" + contador (una sola vez)
        if (!this._btnAdded) {
          const aToolbars = oView.findAggregatedObjects(true, o => o.isA("sap.m.OverflowToolbar"));
          const oToolbar = aToolbars.find(tb =>
            tb.getContent().some(c => c.isA("sap.m.Button") && (c.getText && /Crear|Create/i.test(c.getText())))
          ) || aToolbars[0];

          if (oToolbar) {
            const oBtn = new Button({
              icon: "sap-icon://cart-2",
              type: "Emphasized",
              tooltip: "Ver carrito",
              press: this.openCart.bind(this)
            });
            const oTxt = new Text({
              text: "{cart>/cartCount}",
              wrapping: false,
              layoutData: new OverflowToolbarLayoutData({ priority: "NeverOverflow" })
            });
            oToolbar.insertContent(oBtn, 0);
            oToolbar.insertContent(oTxt, 1);
            this._btnAdded = true;
          }
        }

        // Engancha botones "Agregar" que estén en el árbol de controles ahora mismo
        const aCartButtons = oView.findAggregatedObjects(true, o =>
          o.isA("sap.m.Button") &&
          ((o.getIcon && o.getIcon() === "sap-icon://cart-2") || /AddToCart/i.test(o.getId()))
        );
        aCartButtons.forEach(btn => {
          if (!btn.data("__cartHooked")) {
            btn.data("__cartHooked", true);
            btn.attachPress(() => this._burstPoll(30000)); // 30s de ventana por si hay OPD
          }
        });

        // Hook de respaldo por DOM (cubre clones/OPD)
        this._installDomClickHook();
      },

      onExit: function () {
        // limpia el listener DOM si existiera
        if (this.__onDocClick) {
          document.removeEventListener("click", this.__onDocClick, true);
          this.__onDocClick = null;
          this.__domHookInstalled = false;
        }
        if (this.__burstTimer) {
          clearTimeout(this.__burstTimer);
          this.__burstTimer = null;
        }
      }
    },

    /* ============================================================
     *  Hook DOM – detecta click en cualquier botón con icono carrito
     * ========================================================== */
    _installDomClickHook: function () {
      if (this.__domHookInstalled) return;
      this.__domHookInstalled = true;

      // Usamos fase de captura para no perder clicks.
      this.__onDocClick = (ev) => {
        const btnEl = ev.target.closest(".sapMBtn, .sapMBtnBase");
        if (!btnEl) return;

        const iconEl = btnEl.querySelector(".sapUiIcon");
        const glyph  = iconEl?.getAttribute("data-sap-ui-icon-content") || "";
        const aria   = (btnEl.getAttribute("aria-label") || "");

        // Si es el icono del carrito (o aria lo sugiere), lanzamos el sondeo.
        if (CART_GLYPHS.includes(glyph) || /cart|carrito/i.test(aria)) {
          this._burstPoll(45000); // 45s: suficiente para confirmar la acción + batch
        }
      };

      document.addEventListener("click", this.__onDocClick, true);
    },

    /* ============================================================
     *  Contador (badge)
     * ========================================================== */

    // Llama a la function OData por GET (¡con paréntesis!)
    _getCount: async function () {
      const res = await fetch("/odata/v4/taller/GetCartCount()", { method: "GET" });
      if (!res.ok) throw new Error(`GetCartCount() HTTP ${res.status}`);
      const js = await res.json().catch(() => ({}));
      return (typeof js === "number") ? js : (js.value ?? 0);
    },

    // Lee y pinta el badge
    _syncBadge: async function () {
      try {
        const n = await this._getCount();
        this._cartState.setProperty("/cartCount", Number(n || 0));
      } catch (e) {
        /* eslint-disable no-console */
        console.warn("No se pudo leer GetCartCount()", e);
      }
    },

    // Sondeo “explosivo”: intenta muchas veces dentro de una ventana de tiempo
    _burstPoll: function (windowMs = 10000, stepMs = 1000) {
      const start = Date.now();
      const tick  = async () => {
        try { await this._syncBadge(); } catch {}
        if (Date.now() - start < windowMs) {
          this.__burstTimer = setTimeout(tick, stepMs);
        }
      };
      if (this.__burstTimer) clearTimeout(this.__burstTimer);
      // pequeño retraso inicial para dar tiempo al OPD/batch a arrancar
      wait(300).then(tick);
    },

    /* ============================================================
     *  Popup del carrito
     * ========================================================== */
    openCart: async function () {
      const oView = this.base.getView();

      if (!this._oDialog) {
        this._oDialog = await Fragment.load({
          id: oView.getId(),
          name: "taller.project1.ext.CartDialog",
          controller: this
        });
        oView.addDependent(this._oDialog);
      }

      const oModel = oView.getModel();
      this._oDialog.setModel(oModel);

      const oList = oView.byId("cartList");
      oList.setModel(oModel);
      oList.removeAllItems();

      const oBinding = oModel.bindList("/Cart", null, null, null, {
        $select: "ID,productName,quantity,unitPrice,currency,currency_code,subtotal"
      });

      const aCtx = await oBinding.requestContexts(0, 100);
      let total = 0, curr = "";

      aCtx.forEach(ctx => {
        const o = ctx.getObject();
        total += Number(o.subtotal || 0);
        if (!curr) {
          curr = (typeof o.currency_code === "string" && o.currency_code) ||
                 (o.currency && o.currency.code) ||
                 (typeof o.currency === "string" ? o.currency : "");
        }
        const item = new ObjectListItem({
          title: o.productName,
          number: o.subtotal,
          numberUnit: curr || (o.currency && o.currency.code) || o.currency || "",
          attributes: [
            new ObjectAttribute({
              text: `${o.quantity} x ${Number(o.unitPrice || 0).toFixed(2)} ${curr || (o.currency && o.currency.code) || o.currency || ""}`
            })
          ]
        });
        item.data("ID", o.ID);
        oList.addItem(item);
      });

      const oTxt = oView.byId("cartTotal");
      if (oTxt) oTxt.setText(`Total: ${total.toFixed(2)} ${curr}`);

      // De paso sincroniza el badge
      this._syncBadge();

      this._oDialog.open();
    },

    onDeleteItem: async function (oEvent) {
      const oItem = oEvent.getParameter("listItem");
      const sID   = oItem.data("ID");
      try {
        await this._callAction("taller.RemoveFromCart", { ID: sID });
        await this._reloadCart();
        await this._syncBadge();
      } catch (e) {
        /* eslint-disable no-console */
        console.error(e);
        sap.m.MessageToast.show(e.message || "No se pudo eliminar el ítem del carrito");
      }
    },

    onEmptyCart: async function () {
      try {
        await this._callAction("taller.EmptyCart");
        await this._reloadCart();
        await this._syncBadge();
      } catch (e) {
        /* eslint-disable no-console */
        console.error(e);
        sap.m.MessageToast.show(e.message || "No se pudo vaciar el carrito");
      }
    },

    onNavigateToCart: function () {
      const oNav = this.base.getExtensionAPI().getNavigationService();
      oNav.navigateInternal({ entitySet: "Cart" });
    },

    onCloseCart: function () { if (this._oDialog) this._oDialog.close(); },

    _reloadCart: async function () {
      const oView  = this.base.getView();
      const oModel = oView.getModel();
      const oList  = oView.byId("cartList");
      oList.removeAllItems();

      const oBinding = oModel.bindList("/Cart", null, null, null, {
        $select: "ID,productName,quantity,unitPrice,currency,currency_code,subtotal"
      });

      const aCtx = await oBinding.requestContexts(0, 100);
      let total = 0, curr = "";

      aCtx.forEach(ctx => {
        const o = ctx.getObject();
        total += Number(o.subtotal || 0);
        if (!curr) curr = (o.currency_code || (o.currency && o.currency.code) || o.currency || "");

        const li = new ObjectListItem({
          title: o.productName,
          number: o.subtotal,
          numberUnit: curr || (o.currency && o.currency.code) || o.currency || "",
          attributes: [
            new ObjectAttribute({
              text: `${o.quantity} x ${Number(o.unitPrice || 0).toFixed(2)} ${curr || (o.currency && o.currency.code) || o.currency || ""}`
            })
          ]
        });
        li.data("ID", o.ID);
        oList.addItem(li);
      });

      const oTxt = oView.byId("cartTotal");
      if (oTxt) oTxt.setText(`Total: ${total.toFixed(2)} ${curr}`);
    },

    /* ============================================================
     *  Helper para acciones unbound
     * ========================================================== */
    _callAction: async function (sQualifiedActionName, oParameters) {
      const api = this.base.getExtensionAPI && this.base.getExtensionAPI();
      if (api && typeof api.invokeAction === "function") {
        return api.invokeAction(sQualifiedActionName, {
          bIsBound: false,
          parameters: oParameters || {}
        });
      }
      const url = `/odata/v4/taller/${sQualifiedActionName.split(".").pop()}`;
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(oParameters || {})
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json().catch(() => ({}));
    }
  });
});
