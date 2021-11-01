page 91007 FileBrowser
{
    PageType = Worksheet;
    UsageCategory = None;
    SourceTable = File;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                field(CurrFolder; CurrFolder)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.SetRange(Path, CurrFolder);
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Entries)
            {
                Editable = false;
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                    ApplicationArea = All;
                }
                field("Is a file"; Rec."Is a file")
                {
                    ToolTip = 'Specifies the value of the Is a file field.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        FileRec: Record File;
                    begin
                        if not "Is a file" then begin
                            CurrFolder := CurrFolder + '\' + Rec.Name;
                            CurrFolder := CurrFolder.Replace('\\', '\');
                            //CurrFolder := Rec.Path;
                            // Evaluate Path Expression
                            FileRec.SetRange(Path, CurrFolder);
                            if FileRec.FindFirst() then
                                CurrFolder := FileRec.Path;

                            Rec.SetRange(Path, CurrFolder);
                            CurrPage.Update();
                        end;

                    end;
                }
                field(Path; Rec.Path)
                {
                    ToolTip = 'Specifies the value of the Path field.';
                    ApplicationArea = All;
                }
                field(Size; Rec.Size)
                {
                    ToolTip = 'Specifies the value of the Size field.';
                    ApplicationArea = All;
                }
                field("Time"; Rec."Time")
                {
                    ToolTip = 'Specifies the value of the Time field.';
                    ApplicationArea = All;
                }
            }
        }
    }


    trigger OnOpenPage()
    var
        FileMgt: Codeunit "File Management";
    begin
        if CurrFolder = '' then
            Rec.SetRange(Path, 'C:\')
        else begin
            CurrFolder := FileMgt.GetDirectoryName(CurrFolder);
            Rec.SetRange(Path, CurrFolder);
        end;
    end;

    procedure SetupFileBrowser(CurrFolderNew: text; BrowseForFolderNew: Boolean)
    begin
        BrowseForFolder := BrowseForFolderNew;
        CurrFolder := CurrFolderNew;
    end;

    procedure GetSelectedPath(): Text
    var
        FileMgt: Codeunit "File Management";
    begin
        if BrowseForFolder then
            exit(Rec.Path)
        else begin
            if Rec."Is a file" then
                exit(FileMgt.CombinePath(Rec.Path, Rec.Name))
            else
                exit('');
        end;
    end;

    var
        CurrFolder: Text;
        BrowseForFolder: Boolean;
}