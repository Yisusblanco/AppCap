using {taller as service} from '../services';

annotate service.Inventories with {
    stockNumber  @title: 'Número de Stock'  @Common.FieldControl: #ReadOnly;
    department   @title: 'Departamento';
    min          @title: 'Mínimo'       @Common.FieldControl: #ReadOnly;
    max          @title: 'Máximo'       @Common.FieldControl: #ReadOnly;
    target       @title: 'Objetivo';
    quantity     @title: 'Cantdad'      @Measures.Unit      : baseUnit @Common.FieldControl : #ReadOnly;
    baseUnit     @title: 'Unidad Base'     @Common.IsUnit @Common.FieldControl : #ReadOnly;
};

annotate service.Inventories with {
    department @Common: {
        Text           : department.department,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'VH_Departments',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: department_ID,
                ValueListProperty: 'ID'
            }]
        }
    }
};


annotate service.Inventories with @(
    Common.SemanticKey: [stockNumber],
    UI.HeaderInfo     : {
        $Type         : 'UI.HeaderInfoType',
        TypeName      : 'Inventario',
        TypeNamePlural: 'Inventarios',
        Title         : {
            $Type: 'UI.DataField',
            Value: product.productName
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: product.product
        }
    },
    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: stockNumber
        },
        {
            $Type: 'UI.DataField',
            Value: department_ID
        },
        {
            $Type                : 'UI.DataFieldForAnnotation',
            Target               : '@UI.Chart#Bullet',
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem'
            },
        },
        {
            $Type: 'UI.DataField',
            Value: quantity
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'taller.setStock',
            Label : 'Settear Stock',
            Inline : true
        }
    ],
    UI.DataPoint      : {
        $Type                 : 'UI.DataPointType',
        Value                 : target,
        MinimumValue          : min,
        MaximumValue          : max,
        CriticalityCalculation: {
            $Type                 : 'UI.CriticalityCalculationType',
            ImprovementDirection  : #Maximize,
            ToleranceRangeLowValue: 200,
            DeviationRangeLowValue: 100
        },
    },
    UI.Chart #Bullet  : {
        $Type            : 'UI.ChartDefinitionType',
        ChartType        : #Bullet,
        Measures         : [target],
        MeasureAttributes: [{
            $Type    : 'UI.ChartMeasureAttributeType',
            DataPoint: '@UI.DataPoint',
            Measure  : target
        }]
    },
    UI.FieldGroup     : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: stockNumber
            },
            {
                $Type: 'UI.DataField',
                Value: department_ID
            },
            {
                $Type: 'UI.DataField',
                Value: min
            },
            {
                $Type: 'UI.DataField',
                Value: max
            },
            {
                $Type: 'UI.DataField',
                Value: target
            },
            {
                $Type: 'UI.DataField',
                Value: quantity
            }
        ]
    },
    UI.Facets         : [{
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup',
        Label : 'Inventory Information',
        ID    : 'InventoryInformation'
    }]
);