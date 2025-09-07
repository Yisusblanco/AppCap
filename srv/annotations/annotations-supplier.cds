using { taller as service } from '../services';
using {  } from './annotations-contact';

annotate service.Suppliers with {
  ID 
  @title : 'Proveedor'
  @Common: {
    Text : supplierName,
    TextArrangement : #TextOnly
  };
  supplier @title : 'Proveedor';
  supplierName @title : 'Nombre Proveedor';
  webAddress @title : 'WebSite'
};

annotate service.Suppliers with @(
  UI.FieldGroup #Supplier :{ 
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : supplier                
            },{
                $Type : 'UI.DataField',
                Value : supplierName              
            },{
                $Type : 'UI.DataField',
                Value : webAddress            
            }
        ]
    },
);
