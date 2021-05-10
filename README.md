# PicklistUtils

Apex utility class for working with Picklists with built-in cache.

1. [Working without record types](#working-without-record-types)
    1. Working with object and field references
    1. Working with object and field names as strings
1. [Working with record types](#working-with-record-types)

## Working without record types

### Working with object and field references

```
List<Schema.PicklistEntry> getPicklistValues(
  sObjectType sObjectType,
  Schema.sObjectField field
)
```

Example:

```
List<Schema.PicklistEntry> entries = PicklistUtils.getPicklistValues(
  Account.sObjectType,
  Account.Industry
);
```

### Working with object and field names as strings

```
List<Schema.PicklistEntry> getPicklistValues(
  String objectName,
  String fieldName
)
```

Example:

```
List<Schema.PicklistEntry> entries = PicklistUtils.getPicklistValues(
  'Account',
  'Industry'
);
```

## Working with record types

```
PicklistEntries getPicklistValues(
  String objectName,
  Id recordTypeId,
  String fieldName
)
```

Example:

```
PicklistUtils.PicklistEntries entries = PicklistUtils.getPicklistValues(
  'CustomerRequest__c',
  '0124H000000cz6R',
  'Priority__c'
);
```
