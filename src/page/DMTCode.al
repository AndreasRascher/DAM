page 110012 DMTCode
{
    Caption = 'Code';
    PageType = List;
    UsageCategory = None;
    SourceTableTemporary = true;
    SourceTable = Integer;
    SourceTableView = sorting(Number);
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(Settings)
            {
                field(SourceRecVarName; SourceRecVarName) { Caption = 'Variable Name (Source Record)'; ApplicationArea = All; }
                field(TargetRecVarName; TargetRecVarName) { Caption = 'Variable Name (Target Record)'; ApplicationArea = All; }
            }
            repeater(GroupName)
            {
                field(Line; CodeLines.Get(Rec.Number))
                {
                    Caption = 'Code';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateCode)
            {
                ApplicationArea = All;
                Image = Create;

                trigger OnAction()
                begin
                    CodeLines := CreateFieldMappingCodeBlock(CurrDataFile, SourceRecVarName, TargetRecVarName);
                    ResetLines();
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ResetLines();
    end;

    local procedure CreateFieldMappingCodeBlock(DataFile: Record DMTDataFile; _SourceRecVarName: Text; _TargetRecVarName: Text) CodeLines: List of [Text]
    var
        FieldMapping: Record DMTFieldMapping;
        CodeGenerator: Codeunit DMTCodeGenerator;
        SourceFieldName, TargetFieldName : Text;
    begin
        if not DataFile.FilterRelated(FieldMapping) then
            exit;
        FieldMapping.FindSet(false, false);
        repeat
            FieldMapping.CalcFields("Target Field Name");
            SourceFieldName := CodeGenerator.GetALFieldNameWithMasking(FieldMapping."Target Field Name");
            TargetFieldName := CodeGenerator.GetALFieldNameWithMasking(FieldMapping."Source Field Caption");
            case FieldMapping."Processing Action" of
                DMTFieldProcessingType::FixedValue:
                    begin
                        CodeLines.Add(StrSubstNo('%1.Validate(%2,''%3'');', _TargetRecVarName, TargetFieldName, FieldMapping."Fixed Value"));
                    end;
                DMTFieldProcessingType::Ignore:
                    begin
                        CodeLines.Add(StrSubstNo('//%1.Validate(%2,%3.%4);', _TargetRecVarName, TargetFieldName, _SourceRecVarName, SourceFieldName));
                    end;
                DMTFieldProcessingType::Transfer:
                    begin
                        CodeLines.Add(StrSubstNo('%1.Validate(%2,%3.%4);', _TargetRecVarName, TargetFieldName, _SourceRecVarName, SourceFieldName));
                    end;
            end;

        until FieldMapping.Next() = 0;
    end;


    local procedure ResetLines()
    var
        i: Integer;
    begin
        Rec.DeleteAll();
        for i := 1 to CodeLines.Count do begin
            Rec.Number := i;
            Rec.Insert();
        end;
    end;

    procedure InitForFieldMapping(DataFile: Record DMTDataFile)
    var
        TableMetadata: Record "Table Metadata";
    begin
        CurrDataFile := DataFile;
        TableMetadata.Get(DataFile."Target Table ID");
        SourceRecVarName := DelChr(TableMetadata.Name, '=', ' -') + 'Old';
        TargetRecVarName := DelChr(TableMetadata.Name, '=', ' -');
        CodeLines := CreateFieldMappingCodeBlock(DataFile, SourceRecVarName, TargetRecVarName);
        ResetLines();
    end;

    var
        CurrDataFile: Record DMTDataFile;
        CodeLines: List of [Text];
        SourceRecVarName, TargetRecVarName : Text;
}