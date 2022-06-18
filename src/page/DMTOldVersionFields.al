page 110000 "DMTOldVersionFields"
{
    Caption = 'Old Version Fields', comment = 'Felder alte Version';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTFieldBuffer;

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; }
                field(FieldName; Rec.FieldName) { ApplicationArea = All; }
                field(TableNo; Rec.TableNo) { ApplicationArea = All; }
                field("Type Name"; Rec."Type Name") { ApplicationArea = All; }
            }
        }
    }
}