unit uFilial;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils;

Type
  TFilial = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create(AConn: iConexao = nil);
      destructor Destroy; override;
      class function New(AConn: iConexao = nil): iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TFilial }

constructor TFilial.Create(AConn: iConexao);
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  FEntidadeBase.TextoSQL('Select F.*, 0 as INDICE From FILIAL F where (1 = 1) ');
  FEntidadeBase.TipoPesquisa(1);

  InicializaDataSource;
end;

destructor TFilial.Destroy;
begin
  inherited;
end;

class function TFilial.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TFilial.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TFilial.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and F.STATUS = ''A'' ';

  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' and F.CODIGO = :CodFilial';
  end;

  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  {$IFNDEF APP}
  ModificaDisplayCampos;
  {$ENDIF}
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFilial.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= 'Select F.*, 0 as INDICE From FILIAL F where (1 <> 1) ';
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFilial.ModificaDisplayCampos;
begin
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('cnpj')).EditMask:= '##.###.###/####-##;1;_';
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('cep')).EditMask:= '00000\-999;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('aliquota_simples')).DisplayFormat:= '####0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('aliquota_funrural')).DisplayFormat:= '####0.00';
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('pixavulso_cep')).EditMask:= '00000\-999;1;_';
  FEntidadeBase.Iquery.Dataset.FieldByName('COD_MUNICIPIO').Required:= True;
end;

function TFilial.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
