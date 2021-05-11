/**
 * Utility class for working with Picklists
 */
global with sharing class PicklistUtils {
    // Cache for dynamic Apex calls
    private final static Map<String, List<Schema.PicklistEntry>> apexCache = new Map<String, List<Schema.PicklistEntry>>();

    // Cache for UI API calls
    private final static Map<String, PicklistEntries> uiApiCache = new Map<String, PicklistEntries>();

    /*
     * Retrieves picklist values for a given object and field
     * This method uses dynamic Apex and does not support record types.
     * Example:
     *   List<Schema.PicklistEntry> entries = PicklistUtils.getPicklistValues(Account.sObjectType, Account.Industry);
     * @param sObjectType the object such as Account.sObjectType
     * @param field the object field that is a picklist such as Account.Industry
     */
    public static List<Schema.PicklistEntry> getPicklistValues(
        sObjectType sObjectType,
        Schema.sObjectField field
    ) {
        // Try to get entries from cache
        String cacheKey =
            String.valueOf(sObjectType) +
            '.' +
            String.valueOf(field);
        List<Schema.PicklistEntry> entries = apexCache.get(cacheKey);
        if (entries == null) {
            // Get picklist values
            entries = field.getDescribe().getPicklistValues();
            // Exclude inactive picklist values
            entries = getActivePicklistEntries(entries);
            // Cache entries
            apexCache.put(cacheKey, entries);
        }
        return entries;
    }

    /**
     * Retrieves picklist values for a given object and field
     * This method uses dynamic Apex and does not support record types.
     * @param objectName
     * @param fieldName
     * @throws System.InvalidParameterValueException if objectName or fieldName are invalid
     */
    global static List<Schema.PicklistEntry> getPicklistValues(
        String objectName,
        String fieldName
    ) {
        // Try to get entries from cache
        String cacheKey = objectName + '.' + fieldName;
        List<Schema.PicklistEntry> entries = apexCache.get(cacheKey);
        if (entries == null) {
            // Use dynamic Apex to get object description
            // Schema.describeSObjects throws System.InvalidParameterValueException if objectName is invalid
            Schema.DescribeSobjectResult objDescription = Schema.describeSObjects(
                new List<String>{ objectName }
            )[0];
            // Retrieve field map and check that field exists
            Schema.SObjectField field = objDescription.fields.getMap()
                .get(fieldName);
            if (field == null) {
                InvalidParameterValueException e = new InvalidParameterValueException(
                    'fieldName',
                    fieldName
                );
                e.setMessage(
                    'Could not find field ' +
                    fieldName +
                    ' on object ' +
                    objectName
                );
                throw e;
            }
            // Get picklist values
            entries = field.getDescribe().getPickListValues();
            // Exclude inactive picklist values
            entries = getActivePicklistEntries(entries);
            // Cache entries
            apexCache.put(cacheKey, entries);
        }

        return entries;
    }

    /**
     * Retrieves active picklist values for a given object, record type and field
     * This method uses the UI API and supports record types.
     * @param objectName
     * @param recordTypeId
     * @param fieldName
     */
    global static PicklistEntries getPicklistValues(
        String objectName,
        Id recordTypeId,
        String fieldName
    ) {
        String requestUrl =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/services/data/v51.0/ui-api/object-info/' +
            objectName +
            '/picklist-values/' +
            recordTypeId +
            '/' +
            fieldName;

        // Try to get entries from cache
        PicklistEntries entries = uiApiCache.get(requestUrl);
        if (entries == null) {
            // Prepare UI API request
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setHeader(
                'Authorization',
                'Bearer ' + UserInfo.getSessionId()
            );
            request.setEndpoint(requestUrl);
            // Call UI API
            try {
                HttpResponse httpResponse = new Http().send(request);
                if (httpResponse.getStatusCode() == 200) {
                    // Parse JSON response into PicklistEntries
                    entries = (PicklistEntries) JSON.deserialize(
                        httpResponse.getBody(),
                        PicklistEntries.class
                    );
                    // Cache entries
                    uiApiCache.put(requestUrl, entries);
                } else {
                    System.debug(
                        'HTTP ' +
                        httpResponse.getStatusCode() +
                        ' while calling UI API, Response ' +
                        httpResponse.getBody()
                    );
                    throw new CalloutException(httpResponse.getBody());
                }
            } catch (System.Exception e) {
                System.debug('ERROR: ' + e);
                throw e;
            }
        }

        return entries;
    }

    /**
     * Return active picklist entries
     * @param entries list of picklist entries
     */
    private static List<Schema.PicklistEntry> getActivePicklistEntries(
        List<Schema.PicklistEntry> entries
    ) {
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry);
            }
        }
        return activeEntries;
    }

    global class PicklistEntries {
        global PicklistEntry defaultValue;
        global List<PicklistEntry> values;
    }

    global class PicklistEntry {
        global String label;
        global String value;
    }
}
