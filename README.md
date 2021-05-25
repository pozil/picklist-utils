[![CI Workflow](https://github.com/pozil/picklist-utils/workflows/CI/badge.svg)](https://github.com/pozil/picklist-utils/actions?query=workflow%3ACI) [![Packaging Workflow](https://github.com/pozil/picklist-utils/workflows/Packaging/badge.svg)](https://github.com/pozil/picklist-utils/actions?query=workflow%3APackaging) [![codecov](https://codecov.io/gh/pozil/picklist-utils/branch/main/graph/badge.svg)](https://codecov.io/gh/pozil/picklist-utils)

# PicklistUtils

Apex utility class for working with Picklists with built-in cache.

Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5e000000MIe8AAG) to install the PicklistUtils unlocked package in your org.

Reference:

1. [Working without record types](#working-without-record-types)
    1. Working with object and field references
    1. Working with object and field names as strings
1. [Working with record types](#working-with-record-types)
1. [Working with case statuses](#working-with-case-statuses)

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

## Working with case statuses

```
List<CaseStatus> getCaseStatusValues(
  Boolean isCaseClosed
)
```

Example:

```
List<CaseStatus> values = PicklistUtils.getCaseStatusValues(
  true
);
```
