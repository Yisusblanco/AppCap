using { taller as service } from '../services';

annotate service.Cart with @UI.LineItem: [
  { Value: productName, Label: 'Producto' },
  { Value: quantity,    Label: 'Cant.'   },
  { Value: unitPrice,   Label: 'Precio'  },
  { Value: currency,    Label: 'Mon.'    },
  { Value: subtotal,    Label: 'Subtotal'},
  { $Type: UI.DataFieldForAction, Action: 'taller.Increase', Label: '', IconUrl: 'sap-icon://add',   Inline: true },
  { $Type: UI.DataFieldForAction, Action: 'taller.Decrease', Label: '', IconUrl: 'sap-icon://less',  Inline: true },
  { $Type: UI.DataFieldForAction, Action: 'taller.Remove',   Label: '', IconUrl: 'sap-icon://delete', Inline: true }
];

/* Filtros por defecto en la LR del carrito */
annotate service.Cart.
annotate service.Cart.status @Common.FilterDefaultValue: 'OPEN';
annotate service.Cart with @UI.SelectionFields: [ user, status ];