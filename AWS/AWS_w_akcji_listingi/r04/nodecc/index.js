const blessed = require('blessed');

const screen = blessed.screen({
  autoPadding: true,
  smartCSR: true,
  log: './nodecc.log'
});
screen.title = 'Node Control Center dla AWS';

const content = blessed.box({  
  parent: screen,
  width: '70%',
  height: '90%',
  top: '10%',
  left: '30%',
  border: {
    type: 'none',
    fg: '#ffffff'
  },
  fg: 'white',
  bg: 'blue',
  content: '{bold}Node Control Center dla AWS{/bold}\n\nWybierz jedna z akcji z menu po lewej stronie i nacisnij klawisz Return.\n\nDo powrotu sluzy zawsze klawisz strzalki w lewo.\n\nAby zamknac aplikacje, nacisnij klawisze ESC lub q.',
  tags: true
});

const progress = blessed.progressbar({
  parent: screen,
  width: '70%',
  height: '10%',
  top: '0%',
  left: '30%',
  orientation: 'horizontal',
  border: {
    type: 'line',
    fg: '#ffffff'
  },
  fg: 'white',
  bg: 'blue',
  barFg: 'green',
  barBg: 'green',
  filled: 0
});

const list = blessed.list({  
  parent: screen,
  width: '30%',
  height: '100%',
  top: '0%',
  left: '0%',
  border: {
    type: 'line',
    fg: '#ffffff'
  },
  fg: 'white',
  bg: 'blue',
  selectedBg: 'green',
  mouse: true,
  keys: true,
  vi: true,
  label: 'akcje',
  items: ['wyswietl maszyny wirtualne', 'utworz maszyne wirtualna', 'zamknij maszyne wirtualna']
});
list.on('select', (ev, i) => {
  content.border.type = 'line';
  content.focus();
  list.border.type = 'none';
  open(i);
  screen.render(); 
});
list.focus();

const open = (i) => {
  screen.log('open(' + i + ')');
  if (i === 0) {
    loading();
    require('./lib/listVMs.js')((err, instanceIds) => {
      loaded();
      if (err) {
        log('blad', 'blad w wywolaniu zwrotnym listVMs: ' + err);
      } else {
        const instanceList = blessed.list({
          fg: 'white',
          bg: 'blue',
          selectedBg: 'green',
          mouse: true,
          keys: true,
          vi: true,
          items: instanceIds
        });
        content.append(instanceList);
        instanceList.focus();
        instanceList.on('select', (ev, i) => {
          loading();
          require('./lib/showVM.js')(instanceIds[i], (err, instance) => {
            loaded();
            if (err) {
              log('blad', 'blad w wywolaniu zwrotnym showVM: ' + err);
            } else {
              const vmContent = blessed.box({  
                fg: 'white',
                bg: 'blue',
                content:
                  'InstanceId: ' + instance.InstanceId + '\n' +
                  'InstanceType: ' + instance.InstanceType + '\n' +
                  'LaunchTime: ' + instance.LaunchTime + '\n' +
                  'ImageId: ' + instance.ImageId + '\n' +
                  'PublicDnsName: ' + instance.PublicDnsName
              });
              content.append(vmContent);
            }
            screen.render(); 
          });
        });
        screen.render(); 
      }
      screen.render(); 
    });
  } else if (i === 1) {
    loading();
    require('./lib/listAMIs.js')((err, result) => {
      loaded();
      if (err) {
        log('blad', 'blad w wywolaniu zwrotnym listAMIs: ' + err);
      } else {
        const amiList = blessed.list({
          fg: 'white',
          bg: 'blue',
          selectedBg: 'green',
          mouse: true,
          keys: true,
          vi: true,
          items: result.descriptions
        });
        content.append(amiList);
        amiList.focus();
        amiList.on('select', (ev, i) => {
          const amiId = result.amiIds[i];
          loading();
          require('./lib/listSubnets.js')((err, subnetIds) => {
            loaded();
            if (err) {
              log('blad', 'blad w wywolaniu zwrotnym listSubnets: ' + err);
            } else {
              const subnetList = blessed.list({
                fg: 'white',
                bg: 'blue',
                selectedBg: 'green',
                mouse: true,
                keys: true,
                vi: true,
                items: subnetIds
              });
              content.append(subnetList);
              subnetList.focus();
              subnetList.on('select', (ev, i) => {
                loading();
                require('./lib/createVM.js')(amiId, subnetIds[i], (err) => {
                  loaded();
                  if (err) {
                    log('blad', 'blad w wywolaniu zwrotnym createVM: ' + err);
                  } else {
                    const vmContent = blessed.box({  
                      fg: 'white',
                      bg: 'blue',
                      content: 'uruchamianie ...'
                    });
                    content.append(vmContent);
                  }
                  screen.render(); 
                });
              });
              screen.render(); 
            }
            screen.render(); 
          });
        });
        screen.render(); 
      }
      screen.render(); 
    });
  } else if (i === 2) {
    loading();
    require('./lib/listVMs.js')((err, instanceIds) => {
      loaded();
      if (err) {
        log('blad', 'blad w wywolaniu zwrotnym listVMs: ' + err);
      } else {
        const instanceList = blessed.list({
          fg: 'white',
          bg: 'blue',
          selectedBg: 'green',
          mouse: true,
          keys: true,
          vi: true,
          items: instanceIds
        });
        content.append(instanceList);
        instanceList.focus();
        instanceList.on('select', (ev, i) => {
          loading();
          require('./lib/terminateVM.js')(instanceIds[i], (err) => {
            loaded();
            if (err) {
              log('blad', 'blad w wywolaniu zwrotnym terminateVM: ' + err);
            } else {
              const vmContent = blessed.box({  
                fg: 'white',
                bg: 'blue',
                content: 'zamykanie ...'
              });
              content.append(vmContent);
            }
            screen.render(); 
          });
        });
        screen.render(); 
      }
      screen.render(); 
    });
  } else {
    log('blad', 'nie obslugiwane');
    screen.render(); 
  }
};

screen.key('left', () => {  
  content.border.type = 'none';
  content.children.slice().forEach((child) => {
    content.remove(child);
  });
  list.border.type = 'line';
  list.focus();
  screen.render(); 
});

screen.key(['escape', 'q', 'C-c'], () => { 
  return process.exit(0);
});

let loadingInterval;

const loading = () => {
  progress.reset();
  clearInterval(loadingInterval);
  loadingInterval = setInterval(() => {
    if (progress.filled < 75) {
      progress.progress(progress.filled + 5);
    }
    screen.render(); 
  }, 200);
};

const loaded = () => {
  clearInterval(loadingInterval);
  progress.progress(100);
  screen.render(); 
};

const log = (level, message) => {
  screen.log('[' + level + ']: ' + message);
};

screen.render(); 
