using {taller as service} from '../services';
using {} from './annotations-supplier';


annotate service.Products with {
    product     @title            : 'Producto';
    productName @title            : 'Descripción';
    supplier    @title            : 'Proveedor';
    category    @title            : 'Catogoria';
    subCategory @title            : 'Sub categoria';
    statu       @title            : 'Status';
    rating      @title            : 'Rating';
    price       @title: 'Precio'  @Measures.ISOCurrency: currency;
    currency    @Common.IsCurrency: true;
}

annotate service.Products with {
    statu    @Common: {
        Text           : statu.name,
        TextArrangement: #TextOnly,
    };
    category @Common: {
        Text           : category.category,
        TextArrangement: #TextOnly,
        ValueListWithFixedValues,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'VH_Categories',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: category_ID,
                ValueListProperty: 'ID'
            }]
        }
    };

    subCategory
             @Common: {
        Text           : subCategory.subCategory,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'VH_SubCategories',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterIn',
                    LocalDataProperty: category_ID,
                    ValueListProperty: 'category_ID'
                },
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: subCategory_ID,
                    ValueListProperty: 'ID'
                }
            ]
        }
    };
    supplier
             @Common: {
        Text           : supplier.supplierName,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Suppliers',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: supplier_ID,
                ValueListProperty: 'ID'
            }]
        }
    }
}

annotate service.Products with @(
    UI.HeaderInfo         : {
        $Type         : 'UI.HeaderInfoType',
        typeName      : 'Product',
        TypeNamePlural: 'Products',
        Title         : {
            $Type: 'UI.DataField',
            Value: productName,
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: product,
        },

    },
    UI.SelectionFields    : [
        product,
        supplier_ID,
        category_ID,
        subCategory_ID,
        statu_code
    ], /*Capabilities.FilterRestrictions #filter1: {
         $Type : 'Capabilities.FilterRestrictionsType',
         FilterExpressionRestrictions : [
             {
                 $Type : 'Capabilities.FilterExpressionRestrictionType',
                 AllowedExpressions : 'MultiRangeOrSearchExpression',
             },
         ],
     }, */
    UI.LineItem           : [
        {
            $Type: 'UI.DataField',
            Value: product
        },
        {
            $Type: 'UI.DataField',
            Value: productName,
        },
        {
            $Type             : 'UI.DataField',
            Value             : category_ID,
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            },
        },
        {
            $Type             : 'UI.DataField',
            Value             : subCategory_ID,
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            },
        },
        {
            $Type             : 'UI.DataField',
            Value             : statu_code,
            Criticality       : statu.criticality,
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            },
        },
        {
            $Type             : 'UI.DataFieldForAnnotation',
            Target            : '@UI.DataPoint',
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            },
        },
        {
            $Type             : 'UI.DataField',
            Value             : price,
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '19rem',
            },
        },


    ],
    UI.DataPoint          : {
        $Type        : 'UI.DataPointType',
        Visualization: #Rating,
        Value        : rating

    },
    UI.FieldGroup #HeaderA: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: supplier_ID,
            },
            {
                $Type: 'UI.DataField',
                Value: category_ID,
            },
            {
                $Type: 'UI.DataField',
                Value: subCategory_ID,
            }
        ]
    },
    UI.FieldGroup #HeaderB: {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: description,
        }, ]
    },
    UI.FieldGroup #HeaderC: {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type      : 'UI.DataField',
            Value      : statu_code,
            Criticality: statu.criticality,
            Label      : ''
        }, ]
    },
    UI.FieldGroup #HeaderD: {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: price,
            Label: ''
        }, ]
    },
    UI.HeaderFacets       : [
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#HeaderA',
            ID    : 'HeaderA',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#HeaderB',
            ID    : 'HeaderB',
            Label : 'Descripción del producto',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#HeaderC',
            ID    : 'HeaderC',
            Label : 'Disponibilidad',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#HeaderD',
            ID    : 'HeaderD',
            Label : 'Precio',
        }
    ],

    UI.Facets             : [

    {
        $Type    : 'UI.CollectionFacet',
        Facets: [

            {
                $Type : 'UI.ReferenceFacet',
                Target: 'supplier/@UI.FieldGroup#Supplier',
                Label : 'Información',
            },
            {
                $Type : 'UI.ReferenceFacet',
                Target: 'supplier/contact/@UI.FieldGroup#Contact',
                Label : 'Persona Contacto',
            }
        ],
        Label    : 'Información del proveedor',

    },{
        $Type : 'UI.ReferenceFacet',
        Target : 'detail/@UI.FieldGroup',
        Label: 'Información del producto'

        
    }
    ]

);
