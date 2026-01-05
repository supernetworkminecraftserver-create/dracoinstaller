#!/bin/bash

# Variables globales
SCRIPT_NAME="Felix Studios Installer"
SCRIPT_VERSION="1.0.0"
AUTHOR="Felix Studios"
YEAR="2025 - 2026"
MENU_OPTION=0

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar el banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "============================================================"
    echo "   _____      _ _           _____ _       _                 "
    echo "  |  ___|   _| | |_ ___    |  ___(_)_ __ (_) ___  ___       "
    echo "  | |_ | | | | | __/ __|   | |_  | | '_ \| |/ _ \/ __|      "
    echo "  |  _|| |_| | | |_\__ \   |  _| | | | | | |  __/\__ \      "
    echo "  |_|   \__,_|_|\__|___/   |_|   |_|_| |_|_|\___||___/      "
    echo "                                                            "
    echo "                  Studios | ${YEAR}                         "
    echo -e "${NC}"
    echo "============================================================"
    echo -e "${CYAN}"
    echo "██████╗░██████╗░░█████╗░░█████╗░░█████╗░"
    echo "██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗"
    echo "██║░░██║██████╔╝███████║██║░░╚═╝██║░░██║"
    echo "██║░░██║██╔══██╗██╔══██║██║░░██╗██║░░██║"
    echo "██████╔╝██║░░██║██║░░██║╚█████╔╝╚█████╔╝"
    echo "╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░░╚════╝░"
    echo -e "${NC}"
    echo "============================================================"
    echo ""
}

# Función para mostrar el menú principal
show_main_menu() {
    show_banner
    echo -e "${YELLOW}Main Menu${NC}"
    echo "========================================"
    echo ""
    echo "1) Panel Management"
    echo "2) Daemon Management"
    echo "3) Check Services Status"
    echo "4) View Credits"
    echo "5) Exit"
    echo ""
    echo -n "Select an option [1-5]: "
}

# Función para mostrar el menú del panel
show_panel_menu() {
    clear
    echo -e "${CYAN}"
    echo "========================================"
    echo "        PANEL MANAGEMENT MENU           "
    echo "========================================"
    echo -e "${NC}"
    echo ""
    echo "1) Install Panel"
    echo "2) Restart Panel"
    echo "3) Stop Panel"
    echo "4) Uninstall Panel"
    echo "5) View Panel Logs"
    echo "6) Back to Main Menu"
    echo ""
    echo -n "Select an option [1-6]: "
}

# Función para mostrar el menú del daemon
show_daemon_menu() {
    clear
    echo -e "${CYAN}"
    echo "========================================"
    echo "       DAEMON MANAGEMENT MENU           "
    echo "========================================"
    echo -e "${NC}"
    echo ""
    echo "1) Install Daemon"
    echo "2) Configure Daemon"
    echo "3) Restart Daemon"
    echo "4) Stop Daemon"
    echo "5) Uninstall Daemon"
    echo "6) View Daemon Logs"
    echo "7) Back to Main Menu"
    echo ""
    echo -n "Select an option [1-7]: "
}

# Función para mostrar créditos
show_credits() {
    clear
    echo -e "${CYAN}"
    echo "========================================"
    echo "              CREDITS                   "
    echo "========================================"
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}$SCRIPT_NAME v$SCRIPT_VERSION${NC}"
    echo "Developed by: $AUTHOR"
    echo "Copyright © $YEAR"
    echo ""
    echo "Official GitHub Pages:"
    echo -e "${BLUE}Panel:  https://github.com/teryxlabs/v4panel${NC}"
    echo -e "${BLUE}Daemon: https://github.com/teryxlabs/daemon${NC}"
    echo ""
    echo -e "${GREEN}Special thanks to all contributors!${NC}"
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Función para instalar y configurar PM2
install_pm2() {
    echo -e "${YELLOW}Installing PM2...${NC}"
    if npm install -g pm2 2>/dev/null; then
        echo -e "${GREEN}✅ PM2 installed successfully!${NC}"
        return 0
    else
        echo -e "${YELLOW}Trying with sudo...${NC}"
        if sudo npm install -g pm2 2>/dev/null; then
            echo -e "${GREEN}✅ PM2 installed successfully!${NC}"
            return 0
        else
            echo -e "${RED}Failed to install PM2. Please install manually: npm install -g pm2${NC}"
            return 1
        fi
    fi
}

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}Port $port is already in use!${NC}"
        return 1
    fi
    return 0
}

# Función para instalar el Panel
install_panel() {
    echo -e "${YELLOW}Installing Panel...${NC}"
    echo "========================================"
    echo ""
    
    # Verificar si ya está instalado
    if [ -d "v4panel" ]; then
        echo -e "${YELLOW}Panel directory already exists.${NC}"
        read -p "Do you want to reinstall? (y/N): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            return
        fi
        rm -rf v4panel
    fi
    
    # Clone repository
    echo -e "${YELLOW}Cloning repository...${NC}"
    if git clone https://github.com/teryxlabs/v4panel; then
        echo -e "${GREEN}✅ Repository cloned successfully!${NC}"
    else
        echo -e "${RED}Failed to clone repository${NC}"
        return 1
    fi
    
    # Install Node.js
    echo -e "${YELLOW}Installing Node.js...${NC}"
    curl -sL https://deb.nodesource.com/setup_23.x | sudo bash -
    sudo apt-get update
    sudo apt-get install -y nodejs git
    
    # Navigate to panel directory
    cd v4panel || { echo -e "${RED}Failed to enter panel directory${NC}"; return 1; }
    
    # Install zip and extract
    echo -e "${YELLOW}Installing required packages...${NC}"
    sudo apt install -y zip
    echo -e "${YELLOW}Extracting panel.zip...${NC}"
    unzip -o panel.zip 2>/dev/null || echo -e "${YELLOW}Note: panel.zip not found or already extracted${NC}"
    
    # Install dependencies
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install || { echo -e "${RED}Failed to install dependencies${NC}"; return 1; }
    
    # Run setup commands
    echo -e "${YELLOW}Setting up database...${NC}"
    npm run seed 2>/dev/null || echo -e "${YELLOW}Note: seed command might have failed or not exist${NC}"
    
    echo -e "${YELLOW}Creating admin user...${NC}"
    npm run createUser 2>/dev/null || echo -e "${YELLOW}Note: createUser command might have failed or not exist${NC}"
    
    # Instalar PM2 si no está instalado
    if ! command -v pm2 &> /dev/null; then
        install_pm2
    fi
    
    # Verificar puerto 3000
    echo -e "${YELLOW}Checking port 3000...${NC}"
    if check_port 3000; then
        # Iniciar el panel con PM2
        echo ""
        echo -e "${YELLOW}Starting Panel with PM2...${NC}"
        
        # Buscar archivo principal
        if [ -f "index.js" ]; then
            MAIN_FILE="index.js"
        elif [ -f "app.js" ]; then
            MAIN_FILE="app.js"
        elif [ -f "server.js" ]; then
            MAIN_FILE="server.js"
        elif [ -f "src/index.js" ]; then
            MAIN_FILE="src/index.js"
        else
            echo -e "${RED}Could not find main file. Please start manually.${NC}"
            echo "Common files to check: index.js, app.js, server.js, main.js"
            return 1
        fi
        
        pm2 start $MAIN_FILE --name panel
        if [ $? -eq 0 ]; then
            # Configurar PM2 para inicio automático
            echo -e "${YELLOW}Setting up PM2 startup...${NC}"
            pm2 startup 2>/dev/null || echo -e "${YELLOW}Note: PM2 startup might need manual configuration${NC}"
            pm2 save
            
            # Obtener la IP del servidor
            SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
            
            echo ""
            echo -e "${GREEN}========================================${NC}"
            echo -e "${GREEN}✅ Panel installation and startup COMPLETED!${NC}"
            echo -e "${GREEN}========================================${NC}"
            echo ""
            echo -e "${CYAN}📊 Panel Status:${NC}"
            pm2 list panel
            echo ""
            echo -e "${CYAN}🌐 Access your Panel at:${NC}"
            echo -e "${BLUE}   Local:  http://localhost:3000${NC}"
            echo -e "${BLUE}   Public: http://$SERVER_IP:3000${NC}"
            echo ""
            cd ..
        else
            echo -e "${RED}Failed to start panel with PM2${NC}"
            return 1
        fi
    else
        echo -e "${RED}Port 3000 is already in use.${NC}"
        cd ..
        return 1
    fi
}

# Función para reiniciar el panel
restart_panel() {
    echo -e "${YELLOW}Restarting Panel...${NC}"
    if pm2 restart panel 2>/dev/null; then
        echo -e "${GREEN}✅ Panel restarted successfully!${NC}"
        echo ""
        pm2 list panel
    else
        echo -e "${RED}Failed to restart panel. Is it running?${NC}"
    fi
}

# Función para detener el panel
stop_panel() {
    echo -e "${YELLOW}Stopping Panel...${NC}"
    if pm2 stop panel 2>/dev/null; then
        echo -e "${GREEN}✅ Panel stopped successfully!${NC}"
    else
        echo -e "${RED}Failed to stop panel. Is it running?${NC}"
    fi
}

# Función para desinstalar el panel
uninstall_panel() {
    echo -e "${YELLOW}Uninstalling Panel...${NC}"
    
    # Detener el panel si está corriendo
    if pm2 list | grep -q "panel"; then
        pm2 delete panel 2>/dev/null
        pm2 save 2>/dev/null
    fi
    
    # Eliminar directorio
    if [ -d "v4panel" ]; then
        rm -rf v4panel
        echo -e "${GREEN}✅ Panel directory removed${NC}"
    else
        echo -e "${YELLOW}Panel directory not found${NC}"
    fi
    
    echo -e "${GREEN}✅ Panel uninstalled successfully!${NC}"
}

# Función para ver logs del panel
view_panel_logs() {
    echo -e "${YELLOW}Showing Panel logs (Ctrl+C to exit)...${NC}"
    echo ""
    pm2 logs panel --lines=50
    echo ""
    read -p "Press Enter to continue..."
}

# Función para instalar el Daemon
install_daemon() {
    echo -e "${YELLOW}Installing Daemon...${NC}"
    echo "========================================"
    echo ""
    
    # Verificar si ya está instalado
    if [ -d "daemon" ]; then
        echo -e "${YELLOW}Daemon directory already exists.${NC}"
        read -p "Do you want to reinstall? (y/N): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            return
        fi
        rm -rf daemon
    fi
    
    # Clone repository
    echo -e "${YELLOW}Cloning repository...${NC}"
    if git clone https://github.com/teryxlabs/daemon; then
        echo -e "${GREEN}✅ Repository cloned successfully!${NC}"
    else
        echo -e "${RED}Failed to clone repository${NC}"
        return 1
    fi
    
    # Navigate to daemon directory
    cd daemon || { echo -e "${RED}Failed to enter daemon directory${NC}"; return 1; }
    
    # Install zip and extract
    echo -e "${YELLOW}Installing required packages...${NC}"
    sudo apt install -y zip
    echo -e "${YELLOW}Extracting daemon.zip...${NC}"
    unzip -o daemon.zip 2>/dev/null || echo -e "${YELLOW}Note: daemon.zip not found or already extracted${NC}"
    
    # Entrar al subdirectorio daemon si existe
    if [ -d "daemon" ]; then
        cd daemon || echo "Already in daemon directory"
    fi
    
    # Install dependencies
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install || { echo -e "${RED}Failed to install dependencies${NC}"; return 1; }
    
    # Instalar PM2 si no está instalado
    if ! command -v pm2 &> /dev/null; then
        install_pm2
    fi
    
    # Iniciar el daemon con PM2 primero
    echo ""
    echo -e "${YELLOW}Starting Daemon with PM2...${NC}"
    
    # Buscar archivo principal
    if [ -f "index.js" ]; then
        MAIN_FILE="index.js"
    elif [ -f "app.js" ]; then
        MAIN_FILE="app.js"
    elif [ -f "server.js" ]; then
        MAIN_FILE="server.js"
    elif [ -f "src/index.js" ]; then
        MAIN_FILE="src/index.js"
    else
        echo -e "${RED}Could not find main file. Please start manually.${NC}"
        echo "Common files to check: index.js, app.js, server.js, main.js"
        cd ../..
        return 1
    fi
    
    pm2 start $MAIN_FILE --name daemon
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Daemon started successfully!${NC}"
        echo ""
        echo -e "${YELLOW}Now you need to configure the daemon.${NC}"
        echo "Please run the configuration command:"
        echo -e "${CYAN}npm run configure -- --panel <PANEL_URL> --key <PANEL_KEY>${NC}"
        echo ""
        echo "Example:"
        echo -e "${BLUE}npm run configure -- --panel https://pgc5tp-3000.csb.app --key 09901546-dd49-46d2-ae52-a11f9b108e8b${NC}"
        echo ""
        read -p "Do you want to configure now? (Y/n): " configure_now
        
        if [[ ! $configure_now =~ ^[Nn]$ ]]; then
            configure_daemon_interactive
        fi
        
        # Configurar PM2 para inicio automático
        echo -e "${YELLOW}Setting up PM2 startup...${NC}"
        pm2 startup 2>/dev/null || echo -e "${YELLOW}Note: PM2 startup might need manual configuration${NC}"
        pm2 save
        
        # Obtener la IP del servidor
        SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
        
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}✅ Daemon installation COMPLETED!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo -e "${CYAN}📊 Daemon Status:${NC}"
        pm2 list daemon
        echo ""
        echo -e "${CYAN}🌐 Daemon running on:${NC}"
        echo -e "${BLUE}   Local:  http://localhost:3001${NC}"
        echo -e "${BLUE}   Public: http://$SERVER_IP:3001${NC}"
        echo ""
    else
        echo -e "${RED}Failed to start daemon with PM2${NC}"
        cd ../..
        return 1
    fi
    
    cd ../..
}

# Función para configurar el daemon interactivamente
configure_daemon_interactive() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}        DAEMON CONFIGURATION            ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Please enter the following information:${NC}"
    echo ""
    
    read -p "Panel URL (e.g., https://pgc5tp-3000.csb.app): " panel_url
    read -p "Panel Key (e.g., 09901546-dd49-46d2-ae52-a11f9b108e8b): " panel_key
    
    if [ -z "$panel_url" ] || [ -z "$panel_key" ]; then
        echo -e "${RED}Configuration cancelled. Both URL and Key are required.${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}Configuring daemon with:${NC}"
    echo "Panel URL: $panel_url"
    echo "Panel Key: $panel_key"
    echo ""
    
    # Ejecutar el comando de configuración
    cd daemon
    if [ -d "daemon" ]; then
        cd daemon
    fi
    
    echo -e "${YELLOW}Running configuration command...${NC}"
    if npm run configure -- --panel "$panel_url" --key "$panel_key" 2>/dev/null; then
        echo -e "${GREEN}✅ Daemon configured successfully!${NC}"
    else
        echo -e "${YELLOW}Trying alternative command...${NC}"
        # Intentar con node directamente si el script npm no funciona
        if [ -f "configure.js" ]; then
            node configure.js --panel "$panel_url" --key "$panel_key"
        elif [ -f "scripts/configure.js" ]; then
            node scripts/configure.js --panel "$panel_url" --key "$panel_key"
        else
            echo -e "${RED}Configuration script not found.${NC}"
            echo "Please configure manually by editing config files."
        fi
    fi
    
    cd ../..
}

# Función para configurar el daemon
configure_daemon() {
    echo -e "${YELLOW}Configuring Daemon...${NC}"
    echo "========================================"
    echo ""
    
    if [ ! -d "daemon" ]; then
        echo -e "${RED}Daemon not installed. Please install first.${NC}"
        return 1
    fi
    
    cd daemon
    if [ -d "daemon" ]; then
        cd daemon
    fi
    
    # Verificar si el daemon está corriendo
    if ! pm2 list | grep -q "daemon"; then
        echo -e "${YELLOW}Daemon is not running. Starting it first...${NC}"
        
        # Buscar archivo principal
        if [ -f "index.js" ]; then
            MAIN_FILE="index.js"
        elif [ -f "app.js" ]; then
            MAIN_FILE="app.js"
        elif [ -f "server.js" ]; then
            MAIN_FILE="server.js"
        elif [ -f "src/index.js" ]; then
            MAIN_FILE="src/index.js"
        else
            echo -e "${RED}Could not find main file.${NC}"
            cd ../..
            return 1
        fi
        
        pm2 start $MAIN_FILE --name daemon
    fi
    
    configure_daemon_interactive
    
    # Reiniciar el daemon para aplicar cambios
    echo ""
    echo -e "${YELLOW}Restarting daemon to apply changes...${NC}"
    pm2 restart daemon
    echo -e "${GREEN}✅ Daemon configured and restarted!${NC}"
    
    cd ../..
}

# Función para reiniciar el daemon
restart_daemon() {
    echo -e "${YELLOW}Restarting Daemon...${NC}"
    if pm2 restart daemon 2>/dev/null; then
        echo -e "${GREEN}✅ Daemon restarted successfully!${NC}"
        echo ""
        pm2 list daemon
    else
        echo -e "${RED}Failed to restart daemon. Is it running?${NC}"
    fi
}

# Función para detener el daemon
stop_daemon() {
    echo -e "${YELLOW}Stopping Daemon...${NC}"
    if pm2 stop daemon 2>/dev/null; then
        echo -e "${GREEN}✅ Daemon stopped successfully!${NC}"
    else
        echo -e "${RED}Failed to stop daemon. Is it running?${NC}"
    fi
}

# Función para desinstalar el daemon
uninstall_daemon() {
    echo -e "${YELLOW}Uninstalling Daemon...${NC}"
    
    # Detener el daemon si está corriendo
    if pm2 list | grep -q "daemon"; then
        pm2 delete daemon 2>/dev/null
        pm2 save 2>/dev/null
    fi
    
    # Eliminar directorio
    if [ -d "daemon" ]; then
        rm -rf daemon
        echo -e "${GREEN}✅ Daemon directory removed${NC}"
    else
        echo -e "${YELLOW}Daemon directory not found${NC}"
    fi
    
    echo -e "${GREEN}✅ Daemon uninstalled successfully!${NC}"
}

# Función para ver logs del daemon
view_daemon_logs() {
    echo -e "${YELLOW}Showing Daemon logs (Ctrl+C to exit)...${NC}"
    echo ""
    pm2 logs daemon --lines=50
    echo ""
    read -p "Press Enter to continue..."
}

# Función para verificar estado de servicios
check_services() {
    clear
    echo -e "${CYAN}"
    echo "========================================"
    echo "       SERVICES STATUS CHECK            "
    echo "========================================"
    echo -e "${NC}"
    
    if command -v pm2 &> /dev/null; then
        echo ""
        echo -e "${CYAN}📊 PM2 Process List:${NC}"
        echo "----------------------------------------"
        pm2 list
        
        echo ""
        echo -e "${CYAN}📈 Service Status:${NC}"
        echo "----------------------------------------"
        
        # Verificar Panel
        if pm2 list | grep -q "panel"; then
            echo -e "${GREEN}✅ Panel: RUNNING${NC}"
            PANEL_STATUS=$(pm2 info panel | grep -A 5 "status" | tail -1)
            echo "   Status: $PANEL_STATUS"
        else
            echo -e "${RED}❌ Panel: NOT RUNNING${NC}"
        fi
        
        # Verificar Daemon
        if pm2 list | grep -q "daemon"; then
            echo -e "${GREEN}✅ Daemon: RUNNING${NC}"
            DAEMON_STATUS=$(pm2 info daemon | grep -A 5 "status" | tail -1)
            echo "   Status: $DAEMON_STATUS"
        else
            echo -e "${RED}❌ Daemon: NOT RUNNING${NC}"
        fi
        
        echo ""
        echo -e "${CYAN}🔧 Quick Commands:${NC}"
        echo "----------------------------------------"
        echo "   View all logs:    pm2 logs"
        echo "   View panel logs:  pm2 logs panel"
        echo "   View daemon logs: pm2 logs daemon"
        echo "   Restart all:      pm2 restart all"
        echo "   Save config:      pm2 save"
    else
        echo -e "${YELLOW}PM2 not installed. Services might not be running.${NC}"
        echo ""
        echo "To install PM2: npm install -g pm2"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Función principal del menú del panel
panel_menu() {
    while true; do
        show_panel_menu
        read panel_choice
        
        case $panel_choice in
            1)
                install_panel
                ;;
            2)
                restart_panel
                ;;
            3)
                stop_panel
                ;;
            4)
                uninstall_panel
                ;;
            5)
                view_panel_logs
                ;;
            6)
                return
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Función principal del menú del daemon
daemon_menu() {
    while true; do
        show_daemon_menu
        read daemon_choice
        
        case $daemon_choice in
            1)
                install_daemon
                ;;
            2)
                configure_daemon
                ;;
            3)
                restart_daemon
                ;;
            4)
                stop_daemon
                ;;
            5)
                uninstall_daemon
                ;;
            6)
                view_daemon_logs
                ;;
            7)
                return
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Función principal
main() {
    # Verificar si se está ejecutando como root
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${YELLOW}Warning: Some installation steps require sudo privileges.${NC}"
        echo "You may be prompted for your password during installation."
        echo ""
        read -p "Continue? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            exit 1
        fi
    fi
    
    # Actualizar paquetes
    echo -e "${YELLOW}Updating system packages...${NC}"
    sudo apt-get update 2>/dev/null
    
    while true; do
        show_main_menu
        read choice
        
        case $choice in
            1)
                panel_menu
                ;;
            2)
                daemon_menu
                ;;
            3)
                check_services
                ;;
            4)
                show_credits
                ;;
            5)
                echo ""
                echo -e "${GREEN}Thank you for using Felix Studios Installer!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Please select 1-5.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Manejar señal de salida
trap 'echo -e "\n${YELLOW}Interrupted. Exiting...${NC}"; exit 1' INT

# Ejecutar función principal
main
