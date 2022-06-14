page 110000 PermissionRange
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Permission Range";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Index; Rec.Index) { ApplicationArea = All; }
                field(From; Rec.From) { ApplicationArea = All; }
                field("To"; Rec."To") { ApplicationArea = All; }
                field("Delete Permission"; Rec."Delete Permission") { ApplicationArea = All; }
                field("Execute Permission"; Rec."Execute Permission") { ApplicationArea = All; }
                field("Insert Permission"; Rec."Insert Permission") { ApplicationArea = All; }
                field("Limited Usage Permission"; Rec."Limited Usage Permission") { ApplicationArea = All; }
                field("Modify Permission"; Rec."Modify Permission") { ApplicationArea = All; }
                field("Object Type"; Rec."Object Type") { ApplicationArea = All; }
                field("Read Permission"; Rec."Read Permission") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}