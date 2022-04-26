unit uPetCor;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TPetCor = class(TInterfacedObject, iEntidade)
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

{ TPetCor }

constructor TPetCor.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PET_COR');
end;

destructor TPetCor.Destroy;
begin
  inherited;
end;

class function TPetCor.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPetCor.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPetCor.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPetCor.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TPetCor.ModificaDisplayCampos;
begin

end;

end.
