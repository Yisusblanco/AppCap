using {taller as service} from '../services';

annotate service.Sales with {
    monthCode     @title: 'Código Mes'  @Common.IsCalendarMonth;
    month         @title: 'Mes'       @Common.IsCalendarMonth;
    year          @title: 'Año'        @Common.IsCalendarYear;
    quantitySales @title: 'Cantidad de venta';
};

annotate service.Sales with @(
    Analytics.AggregatedProperty #sum: {
        Name: 'Ventas',
        AggregationMethod : 'sum',
        AggregatableProperty : quantitySales,
        ![@Common.Label] : 'Ventas'
    },
    Aggregation.ApplySupported: {
        Transformations : [
            'aggregate',
            'topcount',
            'bottomcount',
            'identity',
            'concat',
            'groupby',
            'filter',
            'top',
            'skip',
            'orderby',
            'search',
        ],
        GroupableProperties: [
            'month',
            'year'
        ],
        AggregatableProperties : [
            {
                $Type : 'Aggregation.AggregatablePropertyType',
                Property : quantitySales
            }
        ]
    },
    UI.Chart  : {
        $Type : 'UI.ChartDefinitionType',
        ChartType : #Line,
        DynamicMeasures : [
            '@Analytics.AggregatedProperty#sum',
        ],
        Dimensions:[ year, month]
    },
);