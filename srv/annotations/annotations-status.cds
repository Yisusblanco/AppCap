using { taller as service } from '../services';

annotate service.Status with {
    code @title : 'Status'
    @Common: {
    Text : descr,
    TextArrangement : #TextOnly
  }
};
