codeunit 110014 "DMTMappingMgt"
{
    procedure GetMappingForRef(FieldMapping: Record DMTFieldMapping; var SourceRef: RecordRef)
    begin
    end;

    var
        JToken: JsonToken;
        JValue: JsonValue;
        MappingValues: List of [JsonValue];
}