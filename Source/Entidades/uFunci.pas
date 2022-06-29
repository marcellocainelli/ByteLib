unit uFunci;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TFunci = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
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

{ TFunci }

constructor TFunci.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select F.*, 0 as INDICE from FUNCI F where (1 = 1) ');

  InicializaDataSource;
end;

destructor TFunci.Destroy;
begin
  inherited;
end;

class function TFunci.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TFunci.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TFunci.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + ' and CODIGO = :pCod_Funci';
  end;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and F.STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.AddParametro('pCod_Funci', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFunci.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFunci.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtnascimento')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtadimissao')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtdemissao')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtferias')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('cep')).EditMask:= '00000\-999;1;_';
end;

function TFunci.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
