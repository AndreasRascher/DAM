page 110000 DMTFileConfigList
{
    Caption = 'DMT File Config List', Comment = 'de-DE=Datei Konfig. Übersicht';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTFileConfig;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(FileTextEncoding; Rec."File Encoding") { ApplicationArea = All; }
                field("Header Line No."; Rec."Header Line No.") { ApplicationArea = All; }
                field("Key Field Col.Numbers"; Rec."Key Field Col.Numbers") { ApplicationArea = All; }
                field("No. of Columns"; Rec."No. of Columns") { ApplicationArea = All; ToolTip = '<KeyFieldNo1>,<KeyFieldNo2>,...,<KeyFieldNoX>', comment = 'de-DE=<Schlüsselfeldnr1>,<Schlüsselfeldnr2>,...,<SchlüsselfeldnrX>'; }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(AnalyzeFile)
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    ImportFileMgt: Codeunit DMTImportFileMgt;
                    readStream: InStream;
                begin
                    ImportFileMgt.GetReadStreamFromUpload(readStream, Rec.GetTextEncoding());
                    ImportFileMgt.SetCSVProperties(Rec);
                    ImportFileMgt.DefineLinesToImport(1);
                end;
            }
        }
    }
}