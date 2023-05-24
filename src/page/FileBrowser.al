page 73022 FileBrowser
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
                field("Date"; Rec."Date") { ApplicationArea = All; }
                field("Is a file"; Rec."Is a file") { ApplicationArea = All; }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        FileRec: Record File;
                    begin
                        if not Rec."Is a file" then begin
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
                field(Path; Rec.Path) { ApplicationArea = All; }
                field(Size; Rec.Size) { ApplicationArea = All; BlankZero = true; }
                field("Time"; Rec."Time") { ApplicationArea = All; }
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

    procedure SetupFileBrowser(CurrFolderNew: Text; BrowseForFolderNew: Boolean)
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
        BrowseForFolder: Boolean;
        CurrFolder: Text;
}