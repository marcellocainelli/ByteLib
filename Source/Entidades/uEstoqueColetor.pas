unit uEstoqueColetor;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TEstoqueColetor = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;
      procedure ModificaDisplayCampos;
  end;
implementation

uses
  uEntidadeBase;
{ TBanco }
constructor TEstoqueColetor.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From ESTOQUE_COLETOR');
end;

destructor TEstoqueColetor.Destroy;
begin
  inherited;
end;

class function TEstoqueColetor.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueColetor.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueColetor.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  vTextoSql:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSql:= vTextoSql + ' Where ID = :Parametro';
    2: vTextoSql:= vTextoSql + ' Where ENVIADO = :pEnviado';
    3: vTextoSql:= vTextoSql + ' Where BAIXADO = :pBaixado';
  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEstoqueColetor.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueColetor.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
end;

end.
