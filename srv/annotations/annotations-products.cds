using { taller as service } from '../services';
annotate service.Products with {
    product @title : 'Producto';
    productName @title : 'Descripción';
    category @title : 'Catogoria';
    subCategory @title : 'Subcategoria';
    statu @title : 'Status';
    rating @title : 'Rating';
    price @title : 'Precio' @Measures.ISOCurrency : currency;
    currency @Common.IsCurrency: true;
}
annotate service.Products with @(
    UI.LineItem: [{
        $Type : 'UI.DataField',
        Value : product
    },{
        $Type : 'UI.DataField',
        Value : productName,
    },{
        $Type : 'UI.DataField',
        Value : category_ID,
    },
    {
        $Type : 'UI.DataField',
        Value : subCategory_ID,
    },{
        $Type : 'UI.DataField',
        Value : statu_code,
    },{
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint',
        @HTML5.CssDefaults : {
            $Type : 'HTML5.CssDefaultsType',
            width : '10rem',
        },
    },
    {
        $Type : 'UI.DataField',
        Value : price,
    },


    ],
    UI.DataPoint: {
        $Type: 'UI.DataPointType',
        Visualization: #Rating,
        Value: rating

    }
);
