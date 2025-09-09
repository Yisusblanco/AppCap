using {taller as service} from '../services';

annotate service.Reviews with {
    rating     @title: 'Calificación';
    date       @title: 'Fecha';
    user       @title: 'Usuario';
    reviewText @title: 'Opiniones del producto';
};

annotate service.Reviews with @(
    UI.HeaderInfo: {
        $Type         : 'UI.HeaderInfoType',
        TypeName      : 'Opinión del Producto',
        TypeNamePlural: 'Opiniones del Producto',
        Title         : {
            $Type: 'UI.DataField',
            Value: product.productName
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: product.product,
        },
    },
    UI.LineItem  : [
        {
            $Type             : 'UI.DataFieldForAnnotation',
            Target            : '@UI.DataPoint',
            Label             : 'Calificación',
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem'
            },
        },
        {
            $Type: 'UI.DataField',
            Value: date,
        },
        {
            $Type: 'UI.DataField',
            Value: user,
        },
        {
            $Type: 'UI.DataField',
            Value: reviewText,
        }
    ],
    UI.DataPoint : {
        $Type        : 'UI.DataPointType',
        Value        : rating,
        Visualization: #Rating,
    },
    UI.FieldGroup: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: rating,
                Label: 'Calificación'
            },     {
                $Type: 'UI.DataField',
                Value: date,
                Label: 'Fecha',
            },     {
                $Type: 'UI.DataField',
                Value: user,
                Label: 'Usuario',
            },     {
                $Type: 'UI.DataField',
                Value: reviewText,
                Label: 'Opinión del producto'
            },

        ]
    },
    UI.Facets    : [

    {
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup',
        Label : 'Opinion del Producto',
        ID    : 'ReviewProduct'
    }]
);
