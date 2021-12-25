page 91009 "DMT Wizard"
{
    Caption = 'Data Migration Wizard';
    PageType = NavigatePage;
    SourceTable = "DMT Setup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Welcome)
            {
                Visible = Step = 1;
                group("Welcome to Data Migration Tool Setup Wizard")
                {
                    Caption = 'Welcome to Data Migration Tool Setup Wizard.';
                    group(Agenda)
                    {
                        ShowCaption = false;
                        InstructionalText = 'The Data Migration Tool Setup covers 3 different areas';
                        group(Group1)
                        {
                            Caption = '➀ Data Export';
                            InstructionalText = '- Select a Version to export from. Export structural information and Data.';
                        }
                        group(Group2)
                        {
                            Caption = '➁ Data Import';
                            InstructionalText = 'Setup the Folder with the exported data. Define Object IDs for the import objects.';
                        }
                        group(Group3)
                        {
                            Caption = '➂ Data Mapping';
                            InstructionalText = 'Setup a mapping and validaten strategy ';
                        }
                    }
                }
            }
            group("Data Export")
            {
                Visible = Step = 2;
                group(DataSourceSelection)
                {
                    Caption = 'Data Export';
                    field(DataSourceOptions; DataSourceOptions)
                    {
                        ApplicationArea = All;
                        Caption = 'Choose Data Source';
                        trigger OnValidate()
                        begin
                            DataSourceSelection_Classic := false;
                            DataSourceSelection_RTC := false;

                            case DataSourceOptions of
                                DataSourceOptions::"Versions until NAV2009R2":
                                    DataSourceSelection_Classic := true;
                                DataSourceOptions::"Versions from NAV2013 to NAV2018":
                                    DataSourceSelection_RTC := true;
                                DataSourceOptions::"Business Central 13 + 14":
                                    DataSourceSelection_RTC := true;
                            end;
                        end;
                    }
                }
                group(DataSourceSelection_NAVClassic)
                {
                    ShowCaption = false;
                    Visible = DataSourceSelection_Classic;
                    InstructionalText = 'Enter a free DataPort Object ID you can run with your license.';
                    field(DataPortID; Rec."Object ID Export Object")
                    {
                        Caption = 'Export DataPort ID';
                        ApplicationArea = All;
                    }
                    field(DownloadDataPort; 'Download Dataport')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        trigger OnDrillDown()
                        var
                            ObjGen: Codeunit DMTObjectGenerator;
                        begin
                            ObjGen.DownloadFileUTF8(ObjGen.GetNavClassicDataport(Rec."Object ID Export Object"),
                            'Dataport_' + format(Rec."Object ID Export Object") + '_DMTExport.txt');
                        end;
                    }
                }
                group(DataSourceSelection_NAVRTC)
                {
                    ShowCaption = false;
                    Visible = DataSourceSelection_RTC;
                    InstructionalText = 'Enter a free DataPort Object ID you can run with your license.';
                    field(XMLPortID; Rec."Object ID Export Object")
                    {
                        Caption = 'Export XMLPort ID';
                        ApplicationArea = All;
                    }
                    field(DownloadXMLPort; 'Download XMLPort')
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        var
                            ObjGen: Codeunit DMTObjectGenerator;
                        begin
                            ObjGen.DownloadFileUTF8(ObjGen.GetNAVRTCXMLPort(Rec."Object ID Export Object"),
                            'XMLPort_' + format(Rec."Object ID Export Object") + '_DMTExport.txt');
                        end;
                    }
                }
            }
        }

    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }
    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var
        DMTSetup: Record "DMT Setup";
    begin
        Rec.Init();
        if DMTSetup.Get() then
            Rec.TransferFields(DMTSetup);

        Rec.Insert();

        Step := Step::Start;
        ResetControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,Step2,Step3,Finish;
        DataSourceOptions: Option "Select a Datasource","Versions until NAV2009R2","Versions from NAV2013 to NAV2018","Business Central 13 + 14";
        DataSourceSelection: Boolean;
        DataSourceSelection_RTC: Boolean;
        DataSourceSelection_Classic: Boolean;

    // local procedure EnableControls();
    // begin
    //     ResetControls();

    //     case Step of
    //         Step::Start:
    //             ShowStep1();
    //         Step::Step2:
    //             ShowStep2();
    //         Step::Step3:
    //             ShowStep3();
    //         Step::Finish:
    //             ShowStep4();
    //     end;
    // end;

    local procedure StoreRecordVar();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert();
        end;

        GeneralLedgerSetup.TransferFields(Rec, false);
        GeneralLedgerSetup.Modify(true);
    end;


    local procedure FinishAction();
    begin
        StoreRecordVar();
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;
    end;


    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        Step := 1;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
               MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;
}