unit uCategoria;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TCategoria = class(TInterfacedObject, iEntidade)
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

{ TCategoria }

constructor TCategoria.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From CATEGORIAS');
end;

destructor TCategoria.Destroy;
begin
  inherited;
end;

class function TCategoria.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCategoria.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCategoria.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  //FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCategoria.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TCategoria.ModificaDisplayCampos;
begin

end;

end.
