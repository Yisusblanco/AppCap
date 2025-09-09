using {taller as service} from '../services';
using {} from './annotations-supplier';
using {} from './annotations-reviews';
using {} from './annotations-inventories';
using {} from './annotations-sales';
using {} from './annotations-cart';

annotate service.Products with @odata.draft.enabled;


annotate service.Products with {
    product       @title            : 'Producto';
    productName   @title            : 'Descripción';
    description   @UI.MultiLineText;
    supplier      @title            : 'Proveedor';
    category      @title            : 'Catogoria';
    subCategory   @title            : 'Sub categoria';
    statu         @title            : 'Status';
    rating        @title            : 'Calificación';
    price         @title: 'Precio'  @Measures.ISOCurrency: currency_code;
    image         @title            : 'Imagen';
    currency      @Common.IsCurrency: true;
    supplierCloud @title            : 'Proveedor Cloud'
}

annotate service.Products with {
    statu         @Common: {
        Text           : statu.name,
        TextArrangement: #TextOnly,
    };
    category      @Common: {
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
    };
    supplierCloud @Common: {ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'CSuppliers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: supplierCloud_Supplier,
                ValueListProperty: 'ID'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'SupplierName'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'FullName'
            }
        ]
    }

    }
}

annotate service.Products with @(
    Common.SideEffects             : {
        $Type           : 'Common.SideEffectsType',
        SourceProperties: [supplier_ID],
        TargetEntities  : [Supplier]
    },
    UI.HeaderInfo                  : {
        $Type         : 'UI.HeaderInfoType',
        typeName      : 'Product',
        TypeNamePlural: 'Products',
        Title         : {
            $Type: 'UI.DataField',
            Value: productName
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: product
        }

    },
    UI.SelectionFields             : [
        product,
        supplier_ID,
        category_ID,
        subCategory_ID,
        statu_code
    ],
    Capabilities.FilterRestrictions: {
        $Type                       : 'Capabilities.FilterRestrictionsType',
        FilterExpressionRestrictions: [{
            $Type             : 'Capabilities.FilterExpressionRestrictionType',
            Property          : product,
            AllowedExpressions: 'SearchExpression',
        }, ],
    },
    UI.LineItem                    : [
        {
            $Type: 'UI.DataField',
            Value: image
        },
        {
            $Type: 'UI.DataField',
            Value: product
        },
        {
            $Type             : 'UI.DataField',
            Value             : productName,
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '15rem',
            }
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
        // Botón "Agregar al carrito" por fila (acción inline en LineItem)        
        {
            $Type            : 'UI.DataFieldForAction',
            Action           : 'taller.addToCart',
            Label            : '',
            // sin texto
            IconUrl          : 'sap-icon://cart-2',
            // ícono del carrito
            Inline           : true,
            // (opcional) tooltip accesible
            @Common.QuickInfo: 'Agregar al carrito',
             @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '5rem',
            }
        },
        {
            $Type             : 'UI.DataField',
            Value             : price,
            @HTML5.CssDefaults: {
                $Type: 'HTML5.CssDefaultsType',
                width: '12rem',
            }
        }

    ],
    UI.DataPoint                   : {
        $Type        : 'UI.DataPointType',
        Visualization: #Rating,
        Value        : rating

    },
    UI.FieldGroup #image           : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: image,
            Label: ''
        }]
    },
    UI.FieldGroup #HeaderA         : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: supplier_ID,
            },
            {
                $Type: 'UI.DataField',
                Value: supplierCloud_Supplier,
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
    UI.FieldGroup #HeaderB         : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: description
        }, ]
    },
    UI.FieldGroup #HeaderC         : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type                  : 'UI.DataField',
            Value                  : statu_code,
            Criticality            : statu.criticality,
            Label                  : '',
            ![@Common.FieldControl]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                1,
                3
            ]}}
        }, ]
    },
    UI.FieldGroup #HeaderD         : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: price,
            Label: ''
        }, ]
    },
    UI.HeaderFacets                : [
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#image',
            ID    : 'Image',
        },
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

    UI.Facets                      : [

        {
            $Type : 'UI.CollectionFacet',
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
            Label : 'Información del proveedor',

        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: 'detail/@UI.FieldGroup',
            Label : 'Información del producto',
            ID    : 'ProductInformation'

        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: 'toReviews/@UI.LineItem',
            Label : 'Opiniones del producto',
            ID    : 'Reviews'


        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: 'toInventories/@UI.LineItem',
            Label : 'Inventario',
            ID    : 'Inventory'


        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: 'toSales/@UI.Chart',
            Label : 'Ventas',
            ID    : 'Sales'
        }
    ]

);
