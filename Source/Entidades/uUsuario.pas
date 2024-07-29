unit uUsuario;
interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TUsuario = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure OnNewRecord(DataSet: TDataSet);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;
{ TUsuario }
constructor TUsuario.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select U.*, U.COD_CAIXA as CODIGO, 0 as INDICE from USUARIO U Where (1 = 1)');
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;
destructor TUsuario.Destroy;
begin
  inherited;
end;
class function TUsuario.New: iEntidade;
begin
  Result:= Self.Create;
end;
procedure TUsuario.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
  FEntidadeBase.Iquery.DataSet.FieldByName('VENDECOMBUSTIVEL').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('STATUS').AsString:= 'A';
  FEntidadeBase.Iquery.DataSet.FieldByName('TROCAFILIAL').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('LANCAOUTRASSAIDAS').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('COD_DEPTO').AsInteger:= 1;
  FEntidadeBase.Iquery.DataSet.FieldByName('CAIXA_RECEBIMENTO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('CAIXA_MOVIMENTO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('CAIXA_DESPESAS').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('CAIXA_ORCAMENTO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('CAIXA_DEVOLUCAO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('CANCELA_CUPOMFISCAL').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('TP_ASSOCIACAO_FUNCI').AsInteger:= 0;
  FEntidadeBase.Iquery.DataSet.FieldByName('VE_MVTOCX_OUTROSUSUARIOS').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('REIMPRIME_PEDIDO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('RETRANSMITE_NFCE_SAT').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLG_ORCAMENTO_ARQUIVO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('SITE_ACESSO').AsString:= 'F';
  FEntidadeBase.Iquery.DataSet.FieldByName('COD_TABELAPRECOS').AsInteger:= -1;
  FEntidadeBase.Iquery.DataSet.FieldByName('CANCELA_JUROS').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('OCULTO').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('FORMAS_PAGAMENTO').AsInteger:= 0;
  FEntidadeBase.Iquery.DataSet.FieldByName('DASHBOARD').AsString:= 'N';
{$ENDIF}
end;

function TUsuario.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TUsuario.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  If FEntidadeBase.RegraPesquisa = 'Contendo' then
      FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' and U.COD_CAIXA = :mParametro';//busca por código
  End;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and U.STATUS = ''A'' ';
  vTextoSQL:= vTextoSQL + ' and coalesce(U.OCULTO, ''N'') = ''N'' ';
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TUsuario.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TUsuario.ModificaDisplayCampos;
begin
end;
function TUsuario.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.
