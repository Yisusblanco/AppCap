using {taller as service} from '../services';


annotate service.Contacts with {
    fullName    @title: 'Full Name';
    email       @title: 'Email';
    phoneNumber @title: 'Phone Number';
};

annotate service.Contacts with @(UI.FieldGroup #Contact: {
    $Type: 'UI.FieldGroupType',
    Data : [{
        $Type: 'UI.DataField',
        Value: fullName
    }, {
        $Type: 'UI.DataField',
        Value: email
    }, {
        $Type: 'UI.DataField',
        Value: phoneNumber
    }, 
    ],


}

);
