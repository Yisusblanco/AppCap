using { taller as service} from '../services';

annotate service.VH_Departments with {
    ID @title : 'Departments' @Common : { 
        Text : department,
        TextArrangement : #TextOnly
     }
};