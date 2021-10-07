page 90003 "DAMTableList"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMTable;
    CardPageId = DAMTableCard;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("Qty.Lines In Src. Table"; Rec."Qty.Lines In Src. Table")
                {
                    ToolTip = 'Specifies the value of the Qty.Lines In Src. Table field';
                    ApplicationArea = All;
                }
                field("Qty.Lines In Trgt. Table"; Rec."Qty.Lines In Trgt. Table")
                {
                    ToolTip = 'Specifies the value of the Qty.Lines In Trgt. Table field';
                    ApplicationArea = All;
                }
                field("Src.Table ID"; Rec."From Table ID")
                {
                    ToolTip = 'Specifies the value of the Src.Table ID field';
                    ApplicationArea = All;
                }
                field("Trgt.Table ID"; Rec."To Table ID")
                {
                    ToolTip = 'Specifies the value of the Trgt.Table ID field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(XMLExport)
            {
                ApplicationArea = All;
                Image = CreateXMLFile;

                trigger OnAction()
                var
                    XMLBackup: Codeunit XMLBackup;
                begin
                    XMLBackup.Export();
                end;
            }
            action(XMLImport)
            {
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    XMLBackup: Codeunit XMLBackup;
                begin
                    XMLBackup.Import();
                end;
            }
        }
    }
}