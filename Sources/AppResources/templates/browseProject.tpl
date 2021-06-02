<div class="row">
    <div class="col-12">
        <a href="/addDataToProject?projectID={projectID}" class="btn btn-sm btn-success"><i class="fa fa-plus-circle"></i> Dodaj nowe dane</a>
        <hr>
    </div>
</div>
<div class="row">
    <div class="col-12">
        <table class="table table-sm table-striped">
          <thead>
            <tr>
            [START header]
              <th scope="col">{name}</th>
            [END header]
              <th scope="col">Opcje</th>
            </tr>
          </thead>
          <tbody>
            [START row]
            <tr>
              {columns}
              <td>
                <a href="" class="btn btn-sm btn-primary"><i class="fa fa-edit"></i></a>
                <a href="/deleteDataFromProject?projectID={projectID}&dataID={dataID}" class="btn btn-sm btn-danger"><i class="fa fa-trash"></i></a>
              </td>
            </tr>
            [END row]
          </tbody>
        </table>

    </div>
</div>
