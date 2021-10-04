unit uProdutoSerial;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TProdutoSerial = class(TInterfacedObject, iEntidade)
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

{ TProdutoSerial }

constructor TProdutoSerial.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From SERIAIS Where COD_PROD = :pCod_Prod');
end;

destructor TProdutoSerial.Destroy;
begin

  inherited;
end;

class function TProdutoSerial.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoSerial.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoSerial.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and BAIXADO = ''X''';
  FEntidadeBase.Iquery.IndexFieldNames('serial');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoSerial.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoSerial.ModificaDisplayCampos;
begin

end;

end.
