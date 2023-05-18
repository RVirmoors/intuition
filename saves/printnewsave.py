import os
import time
import win32print
import win32ui
from PIL import Image, ImageWin
import shutil

# ====================== MOVE EXISTING PNGs

current_folder = os.getcwd()
oldsaves_folder = os.path.join(current_folder, 'oldsaves0')

# Create oldsaves/ directory if it doesn't exist
if not os.path.exists(oldsaves_folder):
    os.mkdir(oldsaves_folder)

# Check for existing oldsavesX/ folders
existing_folders = [f for f in os.listdir(current_folder) if f.startswith('oldsaves')]
latest_folder_num = max([0] + [int(f[len('oldsaves'):]) for f in existing_folders if f[len('oldsaves'):].isdigit()])
latest_folder = os.path.join(current_folder, f'oldsaves{latest_folder_num}')

# Create new folder if the latest folder already exists
if os.path.exists(latest_folder):
    latest_folder_num += 1
    latest_folder = os.path.join(current_folder, f'oldsaves{latest_folder_num}')
    os.mkdir(latest_folder)

# Move .png files to the latest oldsavesX/ folder
png_files = [f for f in os.listdir(current_folder) if f.endswith('.png')]
for file in png_files:
    src_path = os.path.join(current_folder, file)
    dst_path = os.path.join(latest_folder, file)
    shutil.move(src_path, dst_path)
    print(f"Moved {file} to {latest_folder}")

# Check for and delete empty subfolders within saves/
subfolders = [f for f in os.listdir(current_folder) if os.path.isdir(os.path.join(current_folder, f))]
for folder in subfolders:
    folder_path = os.path.join(current_folder, folder)
    if not os.listdir(folder_path):  # Check if the subfolder is empty
        os.rmdir(folder_path)
        print(f"Deleted empty subfolder: {folder}")

# ================= PRINT ==============

#
# Constants for GetDeviceCaps
#
#
# HORZRES / VERTRES = printable area
#
HORZRES = 8
VERTRES = 10
#
# LOGPIXELS = dots per inch
#
LOGPIXELSX = 88
LOGPIXELSY = 90
#
# PHYSICALWIDTH/HEIGHT = total area
#
PHYSICALWIDTH = 110
PHYSICALHEIGHT = 111
#
# PHYSICALOFFSETX/Y = left / top margin
#
PHYSICALOFFSETX = 112
PHYSICALOFFSETY = 113

print("Waiting to print. Press Ctrl+C to stop.")


# Set the folder to monitor
folder_to_monitor = '.'

# Set the file extension to watch for
file_extension = '.png'

# Keep track of files already processed
processed_files = set()

while True:
    # Get the list of files in the folder
    files = set(os.listdir(folder_to_monitor))

    # Get the new files since last iteration
    new_files = files - processed_files

    # Process new files
    for filename in new_files:
        # Check if file has the correct extension
        if os.path.splitext(filename)[1] == file_extension:

            # Get the default printer name
            printer_name = win32print.GetDefaultPrinter()
            hDC = win32ui.CreateDC()
            hDC.CreatePrinterDC(printer_name)
            printable_area = hDC.GetDeviceCaps(HORZRES), hDC.GetDeviceCaps(VERTRES)
            printer_size = hDC.GetDeviceCaps(PHYSICALWIDTH), hDC.GetDeviceCaps(PHYSICALHEIGHT)
            printer_margins = hDC.GetDeviceCaps(PHYSICALOFFSETX), hDC.GetDeviceCaps(PHYSICALOFFSETY)

            # Print the file
            file_path = os.path.join(folder_to_monitor, filename)
            print(f"Printing {filename}...")

            bmp = Image.open(file_path)
            if bmp.size[0] > bmp.size[1]:
                bmp = bmp.rotate(90)

            ratios = [1.0 * printable_area[0] / bmp.size[0], 1.0 * printable_area[1] / bmp.size[1]]
            scale = min(ratios)

            hDC.StartDoc(file_path)
            hDC.StartPage()

            dib = ImageWin.Dib(bmp)
            scaled_width, scaled_height = [int(scale * i) for i in bmp.size]

            x1 = int((printer_size[0] - scaled_width) / 2)
            y1 = 0 # int((printer_size[1] - scaled_height) / 2)
            x2 = x1 + scaled_width
            y2 = y1 + scaled_height
            dib.draw(hDC.GetHandleOutput(), (x1, y1, x2, y2))

            hDC.EndPage()
            hDC.EndDoc()
            hDC.DeleteDC()
                    
            print(f"{filename} has been printed.")

    # Update processed_files set
    processed_files = files

    # Wait for 1 second before checking again
    time.sleep(1)
