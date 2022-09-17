page 110025 "DMTSelectDataFile"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTDataFileBuffer;

    layout
    {
        area(Content)
        {
            field(HasSchema; SchemaIsImported()) { Caption = 'Schema Data Found'; ApplicationArea = All; }
            repeater(repeater)
            {
                field("DateTime"; Rec."DateTime") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("NAV Src.Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; }
                field("NAV Src.Table Name"; Rec."NAV Src.Table Name") { ApplicationArea = All; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; }
                field(Path; Rec.Path) { ApplicationArea = All; }
                field(Size; Rec.Size) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(ActionName)
            // {
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     begin

            //     end;
            // }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.LoadFiles();
    end;

    procedure SchemaIsImported(): Boolean
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
    begin
        exit(DMTFieldBuffer.IsEmpty);
    end;
}