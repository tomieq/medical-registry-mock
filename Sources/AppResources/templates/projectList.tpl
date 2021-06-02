<div class="row">
    <div class="col-12">
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">Nazwa</th>
              <th scope="col">Status</th>
              <th scope="col">Akcje</th>
            </tr>
          </thead>
          <tbody>
            [START project]
            <tr>
              <td>{name}</td>
              <td>{status}</td>
              <td>
                <a href="/browseProjectDataAdmin?projectID={projectID}" class="btn btn-sm btn-primary"><i class="fa fa-database"></i> Przeglądaj dane</a>
                <a href="/editProject?projectID={projectID}" class="btn btn-sm btn-warning">Edycja konfiguracji</a>
                <a href="/deleteProject?projectID={projectID}" class="btn btn-sm btn-danger"><i class="fa fa-trash"></i> Usuń</a>
              </td>
            </tr>
            [END project]
          </tbody>
        </table>
    </div>
</div>
