using { taller as service } from '../services';

annotate service.Options with {
    code @title : 'Options' @Common: {
        Text : name,
        TextArrangement : #TextOnly
    }
};

annotate service.dialog with {
    option @title: 'Option' @mandatory;
    amount @title : 'Amount' @mandatory;
};

annotate service.dialog with {
    option @Common: {
        ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Options',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : option,
                    ValueListProperty : 'code',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name'
                }
            ]
        },

    }
};