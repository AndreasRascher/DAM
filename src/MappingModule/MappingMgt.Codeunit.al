codeunit 110014 "DMTMappingMgt"
{
    procedure GetMappingForRef(FieldMapping: Record DMTFieldMapping; var SourceRef: RecordRef)
    begin
    end;

    var
        MappingValuesArray: array[30] of Variant;
        MappingValues: List of [JsonValue];
}