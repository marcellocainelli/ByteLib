unit uCst;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TCst = class(TInterfacedObject, iEntidade)
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

{ TCst }

constructor TCst.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From CST');
end;

destructor TCst.Destroy;
begin
  inherited;
end;

class function TCst.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCst.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCst.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCst.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TCst.ModificaDisplayCampos;
begin

end;

end.
