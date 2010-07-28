unit UConsultaFornecedor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UConsultaPadrao, FMTBcd, Menus, AppEvnts, DBClient, Provider,
  ActnList, DB, SqlExpr, ComCtrls, StdCtrls, Grids, DBGrids, Buttons,
  JvExControls, JvGradientHeaderPanel, ExtCtrls;

type
  TConsultaFornecedorForm = class(TConsultaPadraoForm)
    CDSConsultaPESSOA_ID: TIntegerField;
    CDSConsultaATIVO: TSmallintField;
    CDSConsultaDATA_CADASTRO: TSQLTimeStampField;
    CDSConsultaDATA_ULTIMA_ALTERACAO: TSQLTimeStampField;
    CDSConsultaNOME_RAZAO: TStringField;
    CDSConsultaNOME_APELIDO_FANTASIA: TStringField;
    CDSConsultaFORNECEDOR_ID: TIntegerField;
    CDSConsultaCNPJ_CPF: TStringField;
    CDSConsultaTIPO: TStringField;
    CDSConsultaIE_IDENTIDADE: TStringField;
    CDSConsultaIM: TStringField;
    CDSConsultaFILIAL: TSmallintField;
    CDSConsultacalc_tipo: TStringField;
    procedure BTAlterarClick(Sender: TObject);
    procedure BTExcluirClick(Sender: TObject);
    procedure BTNovoClick(Sender: TObject);
    procedure BTPesquisarClick(Sender: TObject);
    procedure CBCriterioSelect(Sender: TObject);
    procedure CDSConsultaCalcFields(DataSet: TDataSet);
    procedure EditValorKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Pesquisar;
  public
    { Public declarations }
  end;

var
  ConsultaFornecedorForm: TConsultaFornecedorForm;

implementation
uses Base, UFuncoes, UCadastroFornecedor;
{$R *.dfm}

procedure TConsultaFornecedorForm.BTAlterarClick(Sender: TObject);
begin
  inherited; //Heran�a

  try
    if not Assigned(CadastroFornecedorForm) then
      CadastroFornecedorForm := TCadastroFornecedorForm.Create(Application);
    BancoDados.Operacao := 'Alterar';
    BancoDados.Id := CDSConsultaFORNECEDOR_ID.Value;
    SBPrincipal.Panels[0].Text := '';
    CadastroFornecedorForm.ShowModal;
  finally
    CDSConsulta.Close;
    CDSConsulta.Open;
    CadastroFornecedorForm.Free;
    CadastroFornecedorForm := nil;
  end;
end;

procedure TConsultaFornecedorForm.BTExcluirClick(Sender: TObject);
begin
  try
    CDSConsulta.DisableControls;
    try
      GeraTrace(BancoDados.Tabela,'Excluindo Registros');
      BancoDados.Conexao.StartTransaction(BancoDados.Transacao);
      if (Mensagem('Deseja realmente Excluir este Registro?',mtConfirmation,[mbYES,mbNO],mrNO,0) = idYES) then
        begin
          BancoDados.qryExecute.SQL.Text := 'delete from fornecedor where fornecedor_id = ' +
            IntToStr(CDSConsultaFORNECEDOR_ID.Value) + ';';
          BancoDados.qryExecute.ExecSQL(True);
          BancoDados.Conexao.Commit(BancoDados.Transacao);
        end
      else
        Abort;
      GeraTrace(BancoDados.Tabela,'Exclus�o Concluida');
    except
        BancoDados.Conexao.Rollback(BancoDados.Transacao);
    end;
    CDSConsulta.Close;
    CDSConsulta.Open;
  finally
    CDSConsulta.EnableControls;
  end;
end;

procedure TConsultaFornecedorForm.BTNovoClick(Sender: TObject);
begin
  try
    if not Assigned(CadastroFornecedorForm) then
      CadastroFornecedorForm := TCadastroFornecedorForm.Create(Application);
    BancoDados.Operacao := 'Inserir';
    SBPrincipal.Panels[0].Text := '';
    CadastroFornecedorForm.ShowModal;
  finally
    CDSConsulta.Close;
    CDSConsulta.Open;
    CadastroFornecedorForm.Free;
    CadastroFornecedorForm := nil;
  end;
end;

procedure TConsultaFornecedorForm.BTPesquisarClick(Sender: TObject);
begin
  Pesquisar;
end;

procedure TConsultaFornecedorForm.CBCriterioSelect(Sender: TObject);
begin
  case CBCriterio.ItemIndex of
    1: begin
      CBCondicao.Items.Clear;
      CBCondicao.Items.Add('<  (Menor que:)');
      CBCondicao.Items.Add('<= (Menor ou igual:)');
      CBCondicao.Items.Add('>= (Maior ou igual:)');
      CBCondicao.Items.Add('>  (Maior:)');
      CBCondicao.Items.Add('=  (Igual:)');
      CBCondicao.Items.Add('<> (Diferente:)');
      CBCondicao.ItemIndex := 4;
    end;
    2,3: begin
      CBCondicao.Items.Clear;
      CBCondicao.Items.Add('= (Igual:)');
      CBCondicao.Items.Add('<> (Diferente:)');
      CBCondicao.Items.Add('Iniciado por');
      CBCondicao.Items.Add('Contendo');
      CBCondicao.Items.Add('Terminado por');
      CBCondicao.ItemIndex := 2;
    end;
  end;

  inherited; //Heran�a
end;

procedure TConsultaFornecedorForm.CDSConsultaCalcFields(DataSet: TDataSet);
begin
  if (CDSConsultaTIPO.Value = 'J') then
    CDSConsultacalc_tipo.Value := 'Pessoa Jur�dica'
  else if (CDSConsultaTIPO.Value = 'F') then
    CDSConsultacalc_tipo.Value := 'Pessoa F�sica';
end;

procedure TConsultaFornecedorForm.EditValorKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key = #13) then
    BTPesquisarClick(Sender);
end;

procedure TConsultaFornecedorForm.FormCreate(Sender: TObject);
begin
  BancoDados.Tabela := 'FORNECEDOR';
  BancoDados.SqlConsulta := '';

  inherited; //Heran�a
end;

procedure TConsultaFornecedorForm.FormShow(Sender: TObject);
begin
  inherited; //Heran�a

  CBCriterioSelect(Sender);
  BTPesquisarClick(Sender);
end;

procedure TConsultaFornecedorForm.Pesquisar;
var
  Criterio, Condicao, Campo, Valor : ShortString;
begin
  try
    CDSConsulta.DisableControls;
    Valor := Trim(UpperCase(EditValor.Text));
    BancoDados.SqlConsulta := 'select p.PESSOA_ID, f.ATIVO, f.DATA_CADASTRO, ' +
      'f.DATA_ULTIMA_ALTERACAO, p.NOME_RAZAO, p.NOME_APELIDO_FANTASIA, f.FORNECEDOR_ID, ' +
      'f.CNPJ_CPF, f.TIPO, f.IE_IDENTIDADE, f.IM, f.FILIAL ' +
      'from PESSOA p, FORNECEDOR f where (f.PESSOA_ID = p.PESSOA_ID)';

    if (Valor <> '') then
      begin
        case CBCriterio.ItemIndex of
          1: Campo := 'f.FORNECEDOR_ID';
          2: Campo := 'p.NOME_RAZAO';
          3: Campo := 'p.NOME_APELIDO_FANTASIA';
        end;

        case CBCriterio.ItemIndex of
          1: begin
            case CBCondicao.ItemIndex of
              0: Condicao := ' and ' + Campo + ' < '   + Valor;
              1: Condicao := ' and ' + Campo + ' <= '  + Valor;
              2: Condicao := ' and ' + Campo + ' >= '  + Valor;
              3: Condicao := ' and ' + Campo + ' > '   + Valor;
              4: Condicao := ' and ' + Campo + ' = '   + Valor;
              5: Condicao := ' and ' + Campo + ' <> '  + Valor;
            end;
          end;
          2,3: begin
            case CBCondicao.ItemIndex of
              0: Condicao := ' and Upper(' + Campo + ') = '       + QuotedStr(Valor);
              1: Condicao := ' and Upper(' + Campo + ') <> '      + QuotedStr(Valor);
              2: Condicao := ' and Upper(' + Campo + ') like '    + QuotedStr(Valor + '%');
              3: Condicao := ' and Upper(' + Campo + ') like '    + QuotedStr('%' + Valor + '%');
              4: Condicao := ' and Upper(' + Campo + ') like '    + QuotedStr(Valor + '%');
            end;
          end;
        end;

        BancoDados.SqlConsulta := BancoDados.SqlConsulta + Condicao;
      end;

    if (CBSituacao.ItemIndex in [0,1]) then
      begin
        if (Pos('where', BancoDados.SqlConsulta) > 0) then
          BancoDados.SqlConsulta := BancoDados.SqlConsulta + ' and f.ATIVO = ' + IntToStr(CBSituacao.ItemIndex)
        else
          BancoDados.SqlConsulta := BancoDados.SqlConsulta + ' where f.ATIVO = ' + IntToStr(CBSituacao.ItemIndex);
      end;

    CDSConsulta.Close;
    qryConsulta.SQL.Text := BancoDados.SqlConsulta;
    CDSConsulta.Open;

    CDSConsulta.Last;
    CDSConsulta.First;
    SBPrincipal.Panels[0].Text := IntToStr(CDSConsulta.RecordCount) + ' Registro(s) Encontrado(s).';
  finally
    CDSConsulta.EnableControls;
  end;
end;

end.