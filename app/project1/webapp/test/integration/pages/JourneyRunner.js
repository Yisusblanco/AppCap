sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"taller/project1/test/integration/pages/ProductsList",
	"taller/project1/test/integration/pages/ProductsObjectPage"
], function (JourneyRunner, ProductsList, ProductsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('taller/project1') + '/index.html',
        pages: {
			onTheProductsList: ProductsList,
			onTheProductsObjectPage: ProductsObjectPage
        },
        async: true
    });

    return runner;
});

