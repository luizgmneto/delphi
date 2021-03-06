unit frmcancelaItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DBTables, Mask, RxToolEdit, RxCurrEdit, Buttons;

type
  TfcancelaItem = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    editItem: TCurrencyEdit;
    btn_OK: TBitBtn;
    btn_voltar: TBitBtn;
    procedure editItemKeyPress(Sender: TObject; var Key: Char);
    procedure btn_okClick(Sender: TObject);
    procedure btn_voltarClick(Sender: TObject);
    procedure editItemChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fcancelaItem: TfcancelaItem;

implementation

{$R *.dfm}

uses UPAF_ECF, checkout, dmSyndac, UBarsa, lite_frmprincipal;

procedure TfcancelaItem.editItemKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
   begin
      key:=#0;
      perform(wm_nextdlgctl,0,0);
   end;
end;

procedure TfcancelaItem.btn_okClick(Sender: TObject);
var
   nValor:double;
   sItem: string;
begin
    if (edititem.Value = 0)
    then edititem.SetFocus
    else begin
         if DM.TPDV.Locate('ITEN',EditItem.Value,[])
         then begin
               if DM.TPDVCANCELADO.AsString<>'S'
               then begin
                     sItem:='';
                     sItem:=(FloatTOstr(edititem.value));

                     AC;
                     if s_ImpFiscal = 'ECF Daruma'
                     then retorno_imp_fiscal:= Daruma_FI_CancelaItemGenerico( pchar(sItem ) )
                     else if s_ImpFiscal = 'ECF Bematech'
                     then retorno_imp_fiscal:= Bematech_FI_CancelaItemGenerico( pchar(sItem ) )
                     else if s_ImpFiscal = 'ECF Elgin'
                     then retorno_imp_fiscal:= Elgin_CancelaItemGenerico( pchar(sItem ) )
                     else if s_ImpFiscal = 'ECF Sweda'
                     then retorno_imp_fiscal:= ECF_CancelaItemGenerico( pchar(sItem ) );
                     DC;

                     Analisa_iRetorno();
                     Retorno_Impressora();

                     if RetornouErro=False
                     then begin
                           DM.TPDV.Edit;
                           DM.TPDVDESCRICAO.Value:='**CANCELADO** '+DM.TPDVDESCRICAO.Value;
                           DM.TPDVCANCELADO.AsString:='S';
                           DM.TPDV.Post;

                           if DM.TPDVGrade.Active
                           then begin
                                DM.TPDVGrade.First;
                                While not DM.TPDVGrade.Eof
                                do begin
                                   if DM.TPDVGrade.Locate('ITEN;COD_PRODUTO',VarArrayOf([DM.TPDVIten.Value,DM.TPDVCODPRODUTO.Value]),[])
                                   then DM.TPDVGrade.Delete
                                   else DM.TPDVGrade.Next;
                                   end;
                                end;

                           nSubTotal:=(nSubTotal-DM.TPDVVL_TOTAL.Value);
                           frmcheckout.editSUBTOTAL.Value:=nSubTotal;
                           frmcheckout.editCodigo.SetFocus;
                           Close;
                           end;
                      end
              else begin
                   Informa('Item j� Cancelado!');
                   EditItem.SetFocus;
                   end;
              end
         else begin
              Informa('Item inexistente no Cupom!');
              EditItem.SetFocus;
              end;
        end;     
end;

procedure TfcancelaItem.btn_voltarClick(Sender: TObject);
begin
     close;
end;

procedure TfcancelaItem.editItemChange(Sender: TObject);
begin
   btn_ok.Default:=true;
end;

procedure TfcancelaItem.FormActivate(Sender: TObject);
begin
   edititem.Text:='';
   editItem.SetFocus;
end;

procedure TfcancelaItem.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key = VK_ESCAPE
   then close;
end;

end.
