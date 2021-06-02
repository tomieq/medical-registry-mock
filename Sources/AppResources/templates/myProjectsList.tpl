<div class="row">
    <div class="col-12">
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">Nazwa</th>
              <th scope="col">Akcje</th>
            </tr>
          </thead>
          <tbody>
            [START project]
            <tr>
              <td>{name}</td>
              <td>
                <a href="/addDataToProject?projectID={projectID}" class="btn btn-sm btn-success"><i class="fa fa-plus-circle"></i> Dodaj nowe dane</a>
                <a href="/browseProjectData?projectID={projectID}" class="btn btn-sm btn-primary"><i class="fa fa-database"></i> Przeglądaj dane</a>
              </td>
            </tr>
            [END project]
          </tbody>
        </table>

    </div>
</div>
