@isTest
global class PicklistUtilsTests {
    @isTest
    static void getPicklistValues_works_with_object_referemce() {
        Test.startTest();
        List<Schema.PicklistEntry> entries = PicklistUtils.getPicklistValues(
            Account.sObjectType,
            Account.Industry
        );
        Test.stopTest();

        System.assert(entries.size() > 0);
    }

    @isTest
    static void getPicklistValues_works_with_strings() {
        Test.startTest();
        List<Schema.PicklistEntry> entries = PicklistUtils.getPicklistValues(
            'Account',
            'Industry'
        );
        Test.stopTest();

        System.assert(entries.size() > 0);
    }

    @isTest
    static void getPicklistValues_fails_when_invalid_objectName() {
        Test.startTest();
        try {
            PicklistUtils.getPicklistValues('Unknown', 'Industry');
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(
                e instanceof InvalidParameterValueException,
                'Expected PicklistUtils.PicklistException, got ' + e
            );
            System.assert(
                e.getMessage().contains('Invalid sobject provided'),
                'Expected exception message to contain "Invalid sobject provided", got ' +
                e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getPicklistValues_fails_when_invalid_fieldName() {
        Test.startTest();
        try {
            PicklistUtils.getPicklistValues('Account', 'Unknown');
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(
                e instanceof InvalidParameterValueException,
                'Expected PicklistUtils.PicklistException, got ' + e
            );
            System.assertEquals(
                'Could not find field Unknown on object Account',
                e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getPicklistValuesWithRecordType_works() {
        Test.setMock(
            HttpCalloutMock.class,
            new MockSimpleHttpResponse(
                200,
                '{"controllerValues": {}, "defaultValue": {"label": "Medium", "value": "Medium"}, "values": [{"label": "Medium","value": "Medium"}]}'
            )
        );

        Test.startTest();
        PicklistUtils.PicklistEntries entries = PicklistUtils.getPicklistValues(
            'a',
            '012000000000000AAA',
            'b'
        );
        Test.stopTest();

        System.assertEquals(1, entries.values.size());
    }

    @isTest
    static void getPicklistValuesWithRecordType_fails_when_error_code() {
        Test.setMock(
            HttpCalloutMock.class,
            new MockSimpleHttpResponse(404, '')
        );

        Test.startTest();
        try {
            PicklistUtils.getPicklistValues('a', '012000000000000AAA', 'c');
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(
                e instanceof CalloutException,
                'Expected CalloutException, got ' + e
            );
        }
        Test.stopTest();
    }

    public class MockSimpleHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public MockSimpleHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }
}
