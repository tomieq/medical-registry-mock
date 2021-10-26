<div class="mt-2 mb-2">
    <a href="/addProject" class="btn btn-purple">+ Dodaj Projekt</a>
</div>

<div class="row mt-2">
    <div class="col-12">
        <table class="table table-sm table-striped">
          <thead>
            <tr>
              <th scope="col">NAZWA</th>
              <th scope="col">STATUS</th>
              <th scope="col">WŁAŚCICIEL</th>
            </tr>
          </thead>
          <tbody>
            [START project]
            <tr>
              <td><a href="/editProject?projectID={projectID}" class="text-gray">{name}</a></td>
              <td><span class="label label-purple">{status}</span></td>
              <td>
                John Doe
              </td>
            </tr>
            [END project]
          </tbody>
        </table>
    </div>
</div>
