
        <table class="table table-sm table-striped" id="groupList">
          <thead>
            <tr>
              <th scope="col">Grupy</th>
              <th scope="col">Czy grupę można kopiować</th>
              <th scope="col">Kolejność</th>
              <th scope="col">Akcje</th>
            </tr>
          </thead>
          <tbody>
            [START group]
            <tr>
              <td><i data-feather="folder" class="text-light-gray mx-2" style="height: 16px;"></i>
                <a href="#" onclick="{openGroupJS}" class="text-gray">{name}</a>
              </td>
              <td><input type="checkbox" class="hand" data-url="{toggleCopyUrl}" onchange="checkboxChanged(this);" {checked} /></td>
              <td>
                <span class="hand" onclick="{moveUpClick}"><i data-feather="arrow-up" class="mx-2" style="height: 16px;"></i></span>
                <span class="hand" onclick="{moveDownClick}"><i data-feather="arrow-down" class="mx-2" style="height: 16px;"></i></span>
              </td>
              <td>
                <div class="dropdown">
                  <button class="btn text-light-gray" type="button" id="g{groupID}" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i data-feather="more-vertical" class="mx-2" style="height: 16px;"></i>
                  </button>
                  <div class="dropdown-menu" aria-labelledby="g{groupID}">
                    <a class="dropdown-item font-14 text-light-gray" href="#" onclick="{onclickRename}">Zmień nazwę</a>
                    <a class="dropdown-item font-14 text-light-gray" href="#" onclick="{onclickDelete}">Usuń</a>
                  </div>
                </div>
              </td>
            </tr>
            [END group]
          </tbody>
        </table>
<div id="result"></div>
