using {taller as service } from '../services';

annotate service.ProductDetails with {
    baseUnit @title : 'Unidad Base';
    width @title : 'Ancho' @Measures.Unit: unitVolume;
    height @title : 'Alto' @Measures.Unit: unitVolume;
    depth @title : 'Profundidad' @Measures.Unit: unitVolume;
    weight @title : 'Peso' @Measures.Unit: unitWeight;
    unitVolume @Common.IsUnit @Common.FieldControl: #ReadOnly;
    unitWeight @Common.IsUnit @Common.FieldControl: #ReadOnly;
};

annotate service.ProductDetails with @(

UI.FieldGroup: {
    $Type : 'UI.FieldGroupType',
    Data :[
        {
            $Type: 'UI.DataField',
            Value : baseUnit,
        }, {
            $Type: 'UI.DataField',
            Value : width
        }, {
            $Type: 'UI.DataField',
            Value : height
        }, {
            $Type: 'UI.DataField',
            Value : depth,
            
        }, {
            $Type: 'UI.DataField',
            Value : weight
        }
    ]
}
)