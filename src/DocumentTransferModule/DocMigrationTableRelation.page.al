page 110007 DMTTableRelation
{
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTDocMigration;
    SourceTableTemporary = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(TableRelation)
            {
                field("Table ID"; Rec."Table ID") { ApplicationArea = All; Editable = false; Visible = false; }
                field("Field ID"; Rec."Field ID") { ApplicationArea = All; Visible = false; }
                field("ParentFieldCaption"; ParentFieldCaptionText /*Rec."Field Caption"*/)
                {
                    CaptionClass = GetTableCaptionAsFieldCaption(ParentTableId);
                    ApplicationArea = All;
                    TableRelation = Field."No." where(TableNo = field("Table ID"));
                    LookupPageId = DMTFieldLookup;
                    trigger OnAfterLookup(Selected: RecordRef)
                    var
                        FieldBuffer: Record DMTFieldBuffer;
                    begin
                        Selected.SetTable(FieldBuffer);
                        Rec."Table ID" := FieldBuffer.TableNo;
                        Rec."Field ID" := FieldBuffer."No.";
                        ParentFieldCaptionText := FieldBuffer."Field Caption";
                    end;

                    trigger OnValidate()
                    var
                        Field: Record Field;
                    begin
                        if Field.Get(Rec."Table ID", ParentFieldCaptionText) then begin
                            Rec."Table ID" := Field.TableNo;
                            Rec."Field ID" := Field."No.";
                            ParentFieldCaptionText := Field."Field Caption";
                        end;
                    end;
                }
                field("Related Table ID"; Rec."Related Table ID") { ApplicationArea = All; Editable = false; Visible = false; }
                field("Related Field ID"; Rec."Related Field ID") { ApplicationArea = All; Visible = false; }
                field("RelatedFieldCaptionText"; RelatedFieldCaptionText)
                {
                    ApplicationArea = All;
                    CaptionClass = GetTableCaptionAsFieldCaption(RelatedTableID);
                    TableRelation = Field."No." where(TableNo = field("Related Table ID"));
                    LookupPageId = DMTFieldLookup;
                    trigger OnAfterLookup(Selected: RecordRef)
                    var
                        FieldBuffer: Record DMTFieldBuffer;
                    begin
                        Selected.SetTable(FieldBuffer);
                        Rec."Related Table ID" := FieldBuffer.TableNo;
                        Rec."Related Field ID" := FieldBuffer."No.";
                        RelatedFieldCaptionText := FieldBuffer."Field Caption";
                    end;

                    trigger OnValidate()
                    var
                        Field: Record Field;
                    begin
                        if Field.Get(Rec."Related Table ID", RelatedFieldCaptionText) then begin
                            Rec."Related Table ID" := Field.TableNo;
                            Rec."Related Field ID" := Field."No.";
                            RelatedFieldCaptionText := Field."Field Caption";
                        end;
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ParentFieldCaptionText);
        Clear(RelatedFieldCaptionText);
        Rec.FilterGroup(4);
        Rec."Table ID" := Rec.GetRangeMin("Table ID");
        Rec."Related Table ID" := Rec.GetRangeMin("Related Table ID");
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Field Caption", "Related Field Caption");
        ParentFieldCaptionText := Rec."Field Caption";
        RelatedFieldCaptionText := Rec."Related Field Caption";
    end;

    procedure InitTableRelationView(parentTableIdNew: Integer; relatedTableIDNew: Integer; var DocMigrationNew: Record DMTDocMigration temporary)
    var
        Debug: Integer;
    begin
        Rec.Copy(DocMigrationNew, true);
        ParentTableId := parentTableIdNew;
        RelatedTableID := relatedTableIDNew;
        Rec.FilterGroup(4);
        Debug := Rec.Count;
        Rec.Setrange("Table ID", parentTableIdNew);
        Debug := Rec.Count;
        Rec.SetRange("Related Table ID", relatedTableIDNew);
        Debug := Rec.Count;
        Rec.FilterGroup(0);
    end;

    local procedure GetTableCaptionAsFieldCaption(tableNo: Integer) ReturnVal: Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(tableNo);
        ReturnVal := '3,' + TableMetadata.Caption;
    end;

    var
        [InDataSet]
        ParentFieldCaptionText, RelatedFieldCaptionText : Text;
        ParentTableId, RelatedTableID : Integer;
}