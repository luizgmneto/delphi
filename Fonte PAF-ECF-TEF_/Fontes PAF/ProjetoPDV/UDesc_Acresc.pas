unit UDesc_Acresc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, Mylabel,
  rxToolEdit, rxCurrEdit;

type
  TFDesc_Acresc = class(TForm)
    RGTipo: TRadioGroup;
    ed_descontoPerc: TCurrencyEdit;
    ed_desconto: TCurrencyEdit;
    myLabel3d3: TmyLabel3d;
    myLabel3d4: TmyLabel3d;
    ESubTotal: TCurrencyEdit;
    ETotal: TCurrencyEdit;
    myLabel3d1: TmyLabel3d;
    myLabel3d2: TmyLabel3d;
    Bevel1: TBevel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ed_descontoExit(Sender: TObject);
    procedure ed_descontoPercExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_descontoPercKeyPress(Sender: TObject; var Key: Char);
    procedure ed_descontoEnter(Sender: TObject);
    procedure ed_descontoPercEnter(Sender: TObject);
  private
    { Private declarations }
    Confirma_Operacao : Boolean;
  public
    { Public declarations }
  end;

var
  FDesc_Acresc: TFDesc_Acresc;

implementation

uses UBarsa, u_fechamento_venda_TEF, checkout, dmsyndAC, lite_frmprincipal,
     UPAF_ECF;

{$R *.dfm}

procedure TFDesc_Acresc.FormKeyPress(Sender: TObject; var Key: Char);
begin
     TabEnter(FDesc_Acresc,Key);
end;

procedure TFDesc_Acresc.ed_descontoExit(Sender: TObject);
begin
     if (Sender is TCurrencyEdit) then
     TCurrencyEdit(Sender).Color:=clWhite;
     
     if Ed_Desconto.Value > ESubTotal.Value
     then begin
          Informa ('O Valor do Desconto/Acr�scimo n�o pode ser Superior ao Valor do Cupom!');
          Ed_Desconto.SetFocus;
          end;
     if RGTipo.ItemIndex=0//Descontos
     then begin
          if ed_desconto.Value < 0
          then begin
               Informa('Valor Inv�lido!');
               ed_desconto.Value:=0;
               ed_desconto.SetFocus
               end
          else ETotal.Value:=(ESubTotal.Value-Ed_Desconto.Value);
          end
     else begin//Acr�scimos
          if Ed_Desconto.Value >= 0
          then ETotal.Value:=(ESubTotal.Value+Ed_Desconto.Value)
          else begin
               Informa('Valor Inv�lido!');
               Ed_Desconto.SetFocus;
               end;
          end;
     Ed_DescontoPerc.Value := ((Ed_Desconto.Value)*100)/(ESubTotal.value);
end;

procedure TFDesc_Acresc.ed_descontoPercExit(Sender: TObject);
begin
     if (Sender is TCurrencyEdit) then
     TCurrencyEdit(Sender).Color:=clWhite;

     if ed_descontoPerc.Value < 0
     then begin
          Informa('Valor Inv�lido!');
          Confirma_Operacao:=False;
          ed_descontoPerc.Value:=0;
          ed_descontoPerc.SetFocus;
          end
     else begin
           Ed_Desconto.Value :=((ESubTotal.value)*(Ed_DescontoPerc.Value)/100);
           if Ed_Desconto.Value > ESubTotal.Value
           then begin
                Informa ('O Valor do Desconto/Acr�scimo n�o pode ser Superior ao Valor do Cupom!');
                Ed_Desconto.SetFocus;
                exit;
                end;
           if RGTipo.ItemIndex=0//Descontos
           then begin
                ETotal.Value:=(ESubTotal.Value-Ed_Desconto.Value);
                Confirma_Operacao:=True;
                end
           else begin//Acr�scimos
                if Ed_Desconto.Value >= 0
                then begin
                     ETotal.Value:=(ESubTotal.Value+Ed_Desconto.Value);
                     Confirma_Operacao:=True;
                     end
                else begin
                     Informa('Valor Inv�lido!');
                     Ed_DescontoPerc.SetFocus;
                     end;
                end;     
          end;
end;

procedure TFDesc_Acresc.FormShow(Sender: TObject);
begin
     Confirma_Operacao:=False;
     ESubTotal.Value:=frmcheckout.editSUBTOTAL.Value;
     ETotal.Value:=frmcheckout.editSUBTOTAL.Value;
end;

procedure TFDesc_Acresc.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     FFechamentoVenda_Tef.ETotalLiquido.Value:=ETotal.Value;
end;

procedure TFDesc_Acresc.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key=VK_Escape
     then Close;
end;

procedure TFDesc_Acresc.ed_descontoPercKeyPress(Sender: TObject;
  var Key: Char);
var
   vPerc_Desc_Usuario, vPerc_Desc_Cedido : Currency;
begin
     if (Key=#13)and(Confirma_Operacao)
     then begin
          if Confirma('Confirma a Opera��o?')=mrYes
          then begin
               if RGTipo.ItemIndex=0
               then begin
                     With DM.QPesquisa
                     do begin
                        Close;
                        Sql.Clear;
                        if ServidorRemoto='OF'
                        then Sql.Add('SELECT ID,PE_MAXIMO_DESCONTO FROM USUARIOS')
                        else Sql.Add('SELECT ID,PE_MAXIMO_DESCONTO FROM USUARIOS_PDV');
                        Sql.Add('WHERE ID=:PID');
                        ParamByName('PID').AsInteger:=n_usuario;
                        Open;
                        vPerc_Desc_Usuario:=FieldByName('PE_MAXIMO_DESCONTO').Value;
                        end;
                     vPerc_Desc_Cedido:=ed_descontoPerc.Value;

                     if vPerc_Desc_Usuario < vPerc_Desc_Cedido
                     then begin
                          Informa('Limite de Desconto Ultrapassado!!'+#13+
                                  'O Seu Limite M�ximo �: '+FormatFloat('#####0.00',vPerc_Desc_Usuario)+' %');
                          ed_desconto.Value:=0;
                          ed_descontoPerc.Value:=0;
                          ETotal.Value:=ESubTotal.Value;
                          ed_Desconto.SetFocus;
                          Exit;
                          end;
                     end;     

               FFechamentoVenda_Tef.ETotalLiquido.Value:=ETotal.Value;
               if RGTipo.ItemIndex=0
               then begin
                    FFechamentoVenda_Tef.vDesconto:=Ed_Desconto.Value;
                    ffechamentovenda_tef.vPercDesconto:=ed_descontoPerc.Value;
                    FFechamentoVenda_Tef.ETotalLiquido.Value:=FFechamentoVenda_Tef.ESubTotal.Value-Ed_Desconto.Value;
                    end
               else begin
                    FFechamentoVenda_Tef.vAcrescimo:=Ed_Desconto.Value;
                    ffechamentovenda_tef.vPercAcrescimo:=ed_descontoPerc.Value;
                    FFechamentoVenda_Tef.ETotalLiquido.Value:=FFechamentoVenda_Tef.ESubTotal.Value+Ed_Desconto.Value;
                    end;
               FFechamentoVenda_Tef.ERecebido.SetFocus;
               FFechamentoVenda_Tef.vConcedido_Desconto:=True;
               Close;
               end
           else Ed_Desconto.SetFocus;
        end;
end;

procedure TFDesc_Acresc.ed_descontoEnter(Sender: TObject);
begin
     if (Sender is TCurrencyEdit) then
     TCurrencyEdit(Sender).Color:=$0080FFFF;
end;

procedure TFDesc_Acresc.ed_descontoPercEnter(Sender: TObject);
begin
     if (Sender is TCurrencyEdit) then
     TCurrencyEdit(Sender).Color:=$0080FFFF;
end;

end.
