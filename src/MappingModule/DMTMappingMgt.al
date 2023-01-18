codeunit 110018 "DMTMappingMgt"
{
    procedure GetMappingForRef(FieldMapping: Record DMTFieldMapping; var SourceRef: RecordRef)
    begin

    end;
    // procedure CreateMappingDescription(mappingCode: Code) description: Text
    // var
    //     MappingCondition: Record "DMTMappingCondition";
    //     firstTime: Boolean;
    // begin
    //     firstTime := true;
    //     MappingCondition.setRange("Mapping Code", mappingCode);
    //     MappingCondition.findSet();
    //     repeat
    //         if firstTime then
    //             firstTime := false
    //         else
    //             description += ' AND ';
    //         description += MappingCondition."Source Field Name" + ' ';
    //         case MappingCondition."Comparison Type" of
    //             Enum::DMTComparisonType::IsEqual:
    //                 description += '=';
    //             Enum::DMTComparisonType::IsLargerThan:
    //                 description += '>';
    //             Enum::DMTComparisonType::IsSmaller:
    //                 description += '<';
    //             Enum::DMTComparisonType::IsEqualOrLarger:
    //                 description += '>=';
    //             Enum::DMTComparisonType::IsEqualOrLower:
    //                 description += '<=';
    //         end;
    //         description += ' ' + MappingCondition."Source Value";
    //     until MappingCondition.Next() = 0;
    // end;

    // procedure ParseMapping(mappingDescription: Text) mappingId: Integer;
    // var
    //     MappingCondition: Record DMTMappingCondition;
    //     conditions: List of [Text];
    //     condition: Text;
    //     sourceField: Text;
    //     comparisonType: Enum "DMTComparisonType";
    //     sourceValue: Text;
    // begin
    //     conditions := mappingDescription.Split(' AND ');
    //     MappingCondition.Insert();
    //     MappingCondition."Mapping ID" := MappingCondition.GetNextMappingID();
    //     mappingId := MappingCondition."Mapping ID";
    //     MappingCondition.Modify();
    //     foreach condition in conditions do begin
    //         sourceField := extract(condition, ' ', 1);
    //         comparisonType := Enum::DMTComparisonType::IsEqual;
    //         if condition.Contains('>') then
    //             comparisonType := Enum::DMTComparisonType::IsLargerThan
    //         else
    //             if condition.Contains('<') then
    //                 comparisonType := Enum::DMTComparisonType::IsSmaller
    //             else
    //                 if condition.Contains('>=') then
    //                     comparisonType := Enum::DMTComparisonType::IsEqualOrLarger
    //                 else
    //                     if condition.Contains('<=') then
    //                         comparisonType := Enum::DMTComparisonType::IsEqualOrLower;
    //         sourceValue := extract(condition, ' ', 2);
    //         MappingCondition.Insert();
    //         MappingCondition."Mapping ID" := mappingId;
    //         MappingCondition."Source Field Name" := sourceField;
    //         MappingCondition."Comparison Type" := comparisonType;
    //         MappingCondition."Source Value" := sourceValue;
    //         MappingCondition.Modify();
    //     end;
    // end;

    // procedure extract(text: Text; separator: Text; occurrence: Integer) result: Text;
    // var
    //     index: Integer;
    //     i: Integer;
    // begin
    //     index := 1;
    //     for i := 1 to occurrence do begin
    //         index := text.IndexOf(separator, index);
    //         if index = 0 then
    //             result := '';
    //         exit;
    //     end;
    //     index := index + StrLen(separator);
    //     result := text.Substring(index, StrLen(text) - index);
    // end;
}