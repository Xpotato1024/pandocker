use native_windows_gui as nwg;
use pdx_installer::{default_install_dir, default_profile_file, run, Command, InstallerOptions};
use std::cell::RefCell;
use std::rc::Rc;

fn main() {
    if let Err(message) = run_gui() {
        let _ = nwg::simple_message("Pandocker-X Installer", &message);
        eprintln!("{message}");
    }
}

fn run_gui() -> Result<(), String> {
    nwg::init().map_err(|err| format!("failed to initialize GUI: {err}"))?;
    nwg::Font::set_global_family("Segoe UI")
        .map_err(|err| format!("failed to set GUI font: {err}"))?;

    let install_dir = default_install_dir()?;
    let profile_file = default_profile_file()?;
    let mut window = nwg::Window::default();
    let mut status_text = nwg::TextBox::default();
    let mut install_button = nwg::Button::default();
    let mut uninstall_button = nwg::Button::default();
    let mut status_button = nwg::Button::default();
    let mut close_button = nwg::Button::default();

    nwg::Window::builder()
        .size((640, 420))
        .position((300, 240))
        .title("Pandocker-X Installer")
        .flags(nwg::WindowFlags::WINDOW | nwg::WindowFlags::VISIBLE)
        .build(&mut window)
        .map_err(|err| format!("failed to build window: {err}"))?;

    nwg::TextBox::builder()
        .flags(
            nwg::TextBoxFlags::VISIBLE
                | nwg::TextBoxFlags::VSCROLL
                | nwg::TextBoxFlags::AUTOVSCROLL
                | nwg::TextBoxFlags::TAB_STOP,
        )
        .readonly(true)
        .text(&initial_text(&install_dir, &profile_file))
        .parent(&window)
        .size((600, 270))
        .position((20, 20))
        .build(&mut status_text)
        .map_err(|err| format!("failed to build status box: {err}"))?;

    nwg::Button::builder()
        .text("Install")
        .parent(&window)
        .size((120, 34))
        .position((20, 310))
        .build(&mut install_button)
        .map_err(|err| format!("failed to build install button: {err}"))?;

    nwg::Button::builder()
        .text("Uninstall")
        .parent(&window)
        .size((120, 34))
        .position((150, 310))
        .build(&mut uninstall_button)
        .map_err(|err| format!("failed to build uninstall button: {err}"))?;

    nwg::Button::builder()
        .text("Status")
        .parent(&window)
        .size((120, 34))
        .position((280, 310))
        .build(&mut status_button)
        .map_err(|err| format!("failed to build status button: {err}"))?;

    nwg::Button::builder()
        .text("Close")
        .parent(&window)
        .size((120, 34))
        .position((500, 310))
        .build(&mut close_button)
        .map_err(|err| format!("failed to build close button: {err}"))?;

    let ui = Rc::new(RefCell::new(GuiState {
        window,
        status_text,
        install_button,
        uninstall_button,
        status_button,
        close_button,
        install_dir,
        profile_file,
    }));

    let window_handle = ui.borrow().window.handle;
    let handler_ui = Rc::clone(&ui);
    let handler =
        nwg::full_bind_event_handler(&window_handle, move |event, _event_data, handle| {
            let ui = handler_ui.borrow();
            match event {
                nwg::Event::OnWindowClose => nwg::stop_thread_dispatch(),
                nwg::Event::OnButtonClick if handle == ui.close_button.handle => {
                    nwg::stop_thread_dispatch();
                }
                nwg::Event::OnButtonClick if handle == ui.install_button.handle => {
                    let text = run_action(Command::Install, &ui.install_dir, &ui.profile_file);
                    ui.status_text.set_text(&text);
                }
                nwg::Event::OnButtonClick if handle == ui.uninstall_button.handle => {
                    let text = run_action(Command::Uninstall, &ui.install_dir, &ui.profile_file);
                    ui.status_text.set_text(&text);
                }
                nwg::Event::OnButtonClick if handle == ui.status_button.handle => {
                    let text = run_action(Command::Status, &ui.install_dir, &ui.profile_file);
                    ui.status_text.set_text(&text);
                }
                _ => {}
            }
        });

    nwg::dispatch_thread_events();
    nwg::unbind_event_handler(&handler);
    Ok(())
}

struct GuiState {
    window: nwg::Window,
    status_text: nwg::TextBox,
    install_button: nwg::Button,
    uninstall_button: nwg::Button,
    status_button: nwg::Button,
    close_button: nwg::Button,
    install_dir: std::path::PathBuf,
    profile_file: std::path::PathBuf,
}

fn initial_text(install_dir: &std::path::Path, profile_file: &std::path::Path) -> String {
    format!(
        "Pandocker-X GUI installer\n\nInstall dir:\n  {}\nProfile file:\n  {}\n\nClick Install to copy pdx.exe and register the PowerShell wrapper.\n",
        install_dir.display(),
        profile_file.display()
    )
}

fn run_action(
    command: Command,
    install_dir: &std::path::Path,
    profile_file: &std::path::Path,
) -> String {
    let options = InstallerOptions {
        command,
        source: None,
        bundle_root: None,
        install_dir: install_dir.to_path_buf(),
        profile_file: profile_file.to_path_buf(),
    };

    match run(&options) {
        Ok(report) => report.lines.join("\r\n"),
        Err(err) => format!("Error:\r\n{err}"),
    }
}
