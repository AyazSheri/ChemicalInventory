from flask import request, jsonify
from flask_restful import Resource
from datetime import datetime
from db_models.models import db, Chemical, User, PI, Building, Room, Space

from flask import request, jsonify
from flask_restful import Resource, reqparse
from werkzeug.security import check_password_hash
from db_models.models import db, User, PI, Room, Building
from sqlalchemy import or_

class AddChemicalResource(Resource):
    def post(self):
        print("DEBUG: AddChemicalResource endpoint called.")
        data = request.get_json()
        print("DEBUG: Received data:", data)

        # Extract fields
        barcode = data.get('barcode')
        name = data.get('name')
        cas_number = data.get('cas_number')
        room_id = data.get('room_id')
        space_id = data.get('space_id')
        amount = data.get('amount')
        unit = data.get('unit')
        expiration_date = data.get('expiration_date')

        # Validation
        if not barcode or not name or not cas_number or not room_id or not amount or not unit:
            response = {'success': False, 'message': 'Missing required fields'}
            print("DEBUG: Response before return:", response)
            return response, 400

        # Check for existing barcode
        print(f"DEBUG: Checking for existing chemical with barcode {barcode}")
        existing_chemical = Chemical.query.filter_by(barcode=barcode).first()
        if existing_chemical:
            print(f"DEBUG: Barcode {barcode} is already in use by chemical ID {existing_chemical.id}.")
            response = {'success': False, 'message': 'This barcode is already in use.'}
            print("DEBUG: Response before return:", response)
            return response, 400
        else:
            print(f"DEBUG: No existing chemical found for barcode {barcode}")

        # Parse expiration date
        expiration_date_parsed = None
        if expiration_date:
            try:
                expiration_date_parsed = datetime.strptime(expiration_date, "%Y-%m-%d")
                print(f"DEBUG: Parsed expiration date: {expiration_date_parsed}")
            except ValueError:
                response = {'success': False, 'message': 'Invalid expiration date format. Use YYYY-MM-DD.'}
                print("DEBUG: Response before return:", response)
                return response, 400
        else:
            print("DEBUG: No expiration date provided.")

        # Calculate total weight in pounds
        total_weight_lbs = amount if unit.lower() in ['lb', 'lbs'] else amount * 2.20462
        print(f"DEBUG: Calculated total weight in lbs: {total_weight_lbs}")

        # Add the new chemical
        try:
            print("DEBUG: Attempting to add new chemical to database.")
            new_chemical = Chemical(
                name=name,
                cas_number=cas_number,
                barcode=barcode,
                room_id=room_id,
                space_id=space_id,
                amount=amount,
                unit=unit,
                expiration_date=expiration_date_parsed,
                total_weight_lbs=total_weight_lbs,
            )
            db.session.add(new_chemical)
            db.session.commit()
            print(f"DEBUG: New chemical added with ID: {new_chemical.id}")

            response = {'success': True, 'message': 'Chemical added successfully.'}
            print("DEBUG: Response before return:", response)
            return response, 201
        except Exception as e:
            print(f"DEBUG: Exception occurred: {e}")
            db.session.rollback()
            response = {'success': False, 'message': 'Failed to add chemical due to a server error.'}
            print("DEBUG: Response before return:", response)
            return response, 500

class AddRoomResource(Resource):
    def post(self):
        print("DEBUG: AddRoomResource endpoint called.")
        data = request.get_json()
        print("DEBUG: Received data:", data)

        pi_id = data.get("pi_id")
        room_number = data.get("room_number")
        building_id = data.get("building_id")
        contact_name = data.get("contact_name")
        contact_phone = data.get("contact_phone")

        # Validate required fields
        if not pi_id or not room_number or not building_id:
            return jsonify({"success": False, "message": "PI ID, Room Number, and Building ID are required"}), 400

        # Add new room
        new_room = Room(
            building_id=building_id,
            room_number=room_number,
            pi_id=pi_id,
            contact_name=contact_name,
            contact_phone=contact_phone
        )
        db.session.add(new_room)
        db.session.commit()

        print(f"DEBUG: Added new room with ID: {new_room.id}")

        # Fetch updated data for the associated PI
        pi = PI.query.get(pi_id)
        if not pi:
            return jsonify({"success": False, "message": "PI not found"}), 404

        rooms = Room.query.filter_by(pi_id=pi.id).all()
        room_data = [
            {
                "room_id": room.id,
                "room_number": room.room_number,
                "building_name": Building.query.get(room.building_id).name,
                "contact_name": room.contact_name,
                "contact_phone": room.contact_phone
            }
            for room in rooms
        ]

        updated_pi = {
            "pi_id": pi.id,
            "pi_name": pi.name,
            "rooms": room_data
        }

        return jsonify({
            "success": True,
            "message": "Room added successfully",
            "updated_pi": updated_pi
        })

class FetchBuildingsResource(Resource):
    def get(self):
        print("DEBUG: BuildingsResource endpoint called.")
        buildings = Building.query.all()
        result = [{"id": building.id, "name": building.name} for building in buildings]
        print("DEBUG: Retrieved buildings:", result)
        return jsonify({"success": True, "buildings": result})

class RoomUpdateFieldResource(Resource):
    def post(self):
        print("DEBUG: RoomUpdateFieldResource endpoint called.")
        
        # Parse the request data
        data = request.get_json()
        print(f"DEBUG: Received data: {data}")
        
        room_id = data.get("room_id")
        if not room_id:
            return jsonify({"success": False, "message": "Room ID is required"}), 400
        
        room = Room.query.get(room_id)
        if not room:
            print(f"DEBUG: Room with ID {room_id} not found.")
            return jsonify({"success": False, "message": "Room not found"}), 404
        
        # Update fields based on the key
        if "contact_name" in data:
            room.contact_name = data["contact_name"]
            print(f"DEBUG: Updated contact_name to: {room.contact_name}")
        if "contact_phone" in data:
            room.contact_phone = data["contact_phone"]
            print(f"DEBUG: Updated contact_phone to: {room.contact_phone}")
        
        try:
            db.session.commit()
            return jsonify({"success": True, "message": "Room updated successfully"})
        except Exception as e:
            print(f"DEBUG: Error while committing changes: {e}")
            return jsonify({"success": False, "message": "Failed to update room"}), 500


class ManageSpaceResource(Resource):
    def post(self):
        print("DEBUG: ManageSpaceResource endpoint called.")
        
        data = request.get_json()
        print(f"DEBUG: Received data: {data}")
        
        space_id = data.get("id")
        room_id = data.get("room_id")
        description = data.get("description")
        space_type = data.get("space_type")
        space_identifier = data.get("space_id")

        # Common validation
        if not room_id:
            return jsonify({"success": False, "message": "Room ID is required"}), 400

        # Handle editing existing space
        if space_id:
            print(f"DEBUG: Editing space with ID: {space_id}")
            space = Space.query.get(space_id)
            if not space:
                return jsonify({"success": False, "message": "Space not found"}), 404

            # Update fields
            space.description = description or space.description
            space.space_type = space_type or space.space_type
            space.space_id = space_identifier or space.space_id
            db.session.commit()
            print(f"DEBUG: Updated space: {space.id}")
            return jsonify({"success": True, "message": "Space updated successfully"})

        # Handle adding a new space
        print("DEBUG: Adding a new space.")
        new_space = Space(
            room_id=room_id,
            description=description,
            space_type=space_type,
            space_id=space_identifier
        )
        db.session.add(new_space)
        db.session.commit()
        print(f"DEBUG: Created new space with ID: {new_space.id}")
        return jsonify({"success": True, "message": "Space created successfully", "id": new_space.id})

class RoomDetailsResource(Resource):
    def post(self):
        print("DEBUG: RoomDetailsResource endpoint called.")
        
        # Get the request data
        data = request.get_json()
        print(f"DEBUG: Received request data: {data}")
        
        room_id = data.get("room_id")
        if not room_id:
            print("DEBUG: Room ID is missing in the request.")
            return jsonify({"success": False, "message": "Room ID is required"}), 400
        
        try:
            # Fetch room details
            room = Room.query.get(room_id)
            if not room:
                print(f"DEBUG: No room found for room_id={room_id}")
                return jsonify({"success": False, "message": "Room not found"}), 404
            
            building = Building.query.get(room.building_id)
            spaces = Space.query.filter_by(room_id=room_id).all()
            
            # Prepare room data
            room_data = {
                "room_id": room.id,
                "room_number": room.room_number,
                "building_name": building.name if building else "Unknown",
                "contact_name": room.contact_name or "",
                "contact_phone": room.contact_phone or "",
                "spaces": [
                    {
                        "id": space.id,
                        "description": space.description or "",
                        "space_type": space.space_type or "",
                        "space_id": space.space_id or ""
                    }
                    for space in spaces
                ]
            }
            print("DEBUG: Prepared room data:", room_data)
            
            return jsonify({"success": True, "room_data": room_data})
        
        except Exception as e:
            print(f"DEBUG: Exception occurred: {e}")
            return jsonify({"success": False, "error": str(e)}), 500

class SearchChemicalsResource(Resource):
    def post(self):
        print("DEBUG: SearchChemicalsResource endpoint called.")

        # Get the request data
        data = request.get_json()
        print(f"DEBUG: Received request data: {data}")

        # Parse query and filter
        query = data.get("query", "").lower()
        filter_option = data.get("filter", "Current Room")
        print(f"DEBUG: Query: {query}, Filter Option: {filter_option}")

        # Parse PI and Room data
        user_pis = data.get("pis", [])
        pi_index = data.get("pi_index")  # Selected PI index
        room_index = data.get("room_index")  # Selected Room index
        print(f"DEBUG: User PIs: {user_pis}, PI Index: {pi_index}, Room Index: {room_index}")

        try:
            chemicals = []

            if filter_option == "Current Room" and pi_index is not None and room_index is not None:
                # Get the room_id for the selected PI and Room
                pi_data = user_pis[pi_index] if pi_index < len(user_pis) else None
                if pi_data:
                    room_data = pi_data["rooms"][room_index] if room_index < len(pi_data["rooms"]) else None
                    room_id = room_data["room_id"] if room_data else None
                    print(f"DEBUG: Current Room ID resolved: {room_id}")

                    # Query chemicals in the specific room
                    if room_id:
                        chemicals = Chemical.query.filter(
                            Chemical.room_id == room_id,
                            db.or_(
                                Chemical.name.ilike(f"%{query}%"),
                                Chemical.cas_number.ilike(f"%{query}%"),
                                Chemical.barcode.ilike(f"%{query}%")
                            )
                        ).all()
                        print(f"DEBUG: Found {len(chemicals)} chemicals for Current Room.")

            elif filter_option == "Current PI" and pi_index is not None:
                # Get room_ids for the selected PI
                pi_data = user_pis[pi_index] if pi_index < len(user_pis) else None
                if pi_data:
                    room_ids = [room["room_id"] for room in pi_data["rooms"]]
                    print(f"DEBUG: Room IDs for Current PI: {room_ids}")

                    # Query chemicals in all rooms for the selected PI
                    chemicals = Chemical.query.filter(
                        Chemical.room_id.in_(room_ids),
                        db.or_(
                            Chemical.name.ilike(f"%{query}%"),
                            Chemical.cas_number.ilike(f"%{query}%"),
                            Chemical.barcode.ilike(f"%{query}%")
                        )
                    ).all()
                    print(f"DEBUG: Found {len(chemicals)} chemicals for Current PI.")

            elif filter_option == "All PIs":
                # Get room_ids for all PIs
                room_ids = [room["room_id"] for pi in user_pis for room in pi["rooms"]]
                print(f"DEBUG: Room IDs for All PIs: {room_ids}")

                # Query chemicals in all rooms for all PIs
                chemicals = Chemical.query.filter(
                    Chemical.room_id.in_(room_ids),
                    db.or_(
                        Chemical.name.ilike(f"%{query}%"),
                        Chemical.cas_number.ilike(f"%{query}%"),
                        Chemical.barcode.ilike(f"%{query}%")
                    )
                ).all()
                print(f"DEBUG: Found {len(chemicals)} chemicals for All PIs.")

            else:
                print("DEBUG: Invalid filter or missing indices.")

            # Use the exact response format you provided
            results = [
                {
                    "name": chemical.name,
                    "barcode": chemical.barcode,
                    "room_number": Room.query.get(chemical.room_id).room_number,
                    "building_name": Building.query.get(Room.query.get(chemical.room_id).building_id).name,
                }
                for chemical in chemicals
            ]
            print(f"DEBUG: Prepared {len(results)} results.")

            return jsonify({"success": True, "results": results})

        except Exception as e:
            print(f"DEBUG: Exception occurred: {e}")
            return jsonify({"success": False, "error": str(e)}), 500



class ChemicalDelete(Resource):
    def delete(self, chemical_id):
        print(f"DEBUG: Received DELETE request for chemical ID: {chemical_id}")

        # Fetch the chemical by ID
        chemical = Chemical.query.get(chemical_id)
        if not chemical:
            print(f"DEBUG: Chemical with ID {chemical_id} not found")
            return {"message": "Chemical not found"}, 404

        try:
            db.session.delete(chemical)
            db.session.commit()
            print(f"DEBUG: Chemical with ID {chemical_id} deleted successfully")
            return {"message": "Chemical deleted successfully"}, 200
        except Exception as e:
            db.session.rollback()
            print(f"DEBUG: Error deleting chemical - {str(e)}")
            return {"message": f"Error deleting chemical: {str(e)}"}, 500


class ChemicalEdit(Resource):
    def put(self):
        print("DEBUG: Received PUT request for updating chemical")  # Debug start
        print(f"DEBUG: Request headers: {request.headers}") 

        # Define the expected fields in the request
        parser = reqparse.RequestParser()
        parser.add_argument('id', type=int, required=True, help="Chemical ID is required")
        parser.add_argument('name', type=str, required=True, help="Chemical name is required")
        parser.add_argument('cas_number', type=str, required=True, help="CAS number is required")
        parser.add_argument('amount', type=float, required=True, help="Amount is required")
        parser.add_argument('unit', type=str, required=True, help="Unit is required")
        parser.add_argument('expiration_date', type=str, required=True, help="Expiration date is required")
        parser.add_argument('space_id', type=int, required=True, help="Space ID is required")

        try:
            args = parser.parse_args()
            print(f"DEBUG: Parsed arguments: {args}")  # Debug parsed arguments
        except Exception as e:
            print(f"DEBUG: Failed to parse arguments - {str(e)}")  # Debug parsing failure
            return {'message': f'Error parsing arguments: {str(e)}'}, 400

        # Fetch the chemical by ID
        chemical = Chemical.query.get(args['id'])
        if not chemical:
            print(f"DEBUG: Chemical with ID {args['id']} not found")  # Debug chemical lookup
            return {'message': 'Chemical not found'}, 404
        
        # Convert expiration_date from string to datetime.date
        try:
            expiration_date = datetime.strptime(args['expiration_date'], '%Y-%m-%d').date()
        except ValueError as e:
            print(f"DEBUG: Invalid date format for expiration_date - {str(e)}")
            return {'message': 'Invalid expiration date format. Use YYYY-MM-DD'}, 400

        # Update chemical fields
        try:
            chemical.name = args['name']
            chemical.cas_number = args['cas_number']
            chemical.amount = args['amount']
            chemical.unit = args['unit']
            chemical.expiration_date = expiration_date
            chemical.space_id = args['space_id']
            print(f"DEBUG: Updated chemical object: {chemical}")  # Debug updated chemical object

            db.session.commit()
            print("DEBUG: Successfully committed changes to the database")  # Debug success
            return {'message': 'Chemical updated successfully'}, 200
        except Exception as e:
            db.session.rollback()
            print(f"DEBUG: Error updating chemical - {str(e)}")  # Debug database failure
            return {'message': f'Error updating chemical: {str(e)}'}, 500

class SpaceResource(Resource):
    def get(self, room_id):
        spaces = Space.query.filter_by(room_id=room_id).all()
        return [{"id": space.id, "name": space.description} for space in spaces], 200

class CheckChemical(Resource):
    def post(self):
        try:
            # Parse request data
            data = request.get_json()
            barcode = data.get('barcode')
            selected_room_id = data.get('selected_room_id')

            if not barcode or not selected_room_id:
                print("DEBUG: Missing barcode or selected_room_id in request")
                return {"error": "barcode and selected_room_id are required"}, 400

            print(f"DEBUG: Received barcode: {barcode}, selected_room_id: {selected_room_id}")

            # Query chemical by barcode
            chemical = Chemical.query.filter_by(barcode=barcode).first()

            if not chemical:
                print(f"DEBUG: Chemical with barcode {barcode} not found")
                return {"alert": "Sorry, that chemical is not found"}, 404

            print(f"DEBUG: Found chemical: {chemical}")

            # Fetch the associated Room
            room = Room.query.get(chemical.room_id)
            if not room:
                print(f"DEBUG: Room with ID {chemical.room_id} not found")
                return {"error": "Room not found for this chemical"}, 404

            # Fetch the associated Building
            building = Building.query.get(room.building_id)
            building_name = building.name if building else "Unknown Building"

            # Fetch the associated Space
            space = chemical.space
            space_description = space.description if space else None

            # Check if the room matches
            if chemical.room_id != selected_room_id:
                print(f"DEBUG: Room mismatch for chemical. Expected {selected_room_id}, found {chemical.room_id}")
                room_number = room.room_number if room else "Unknown Room"
                return {
                    "alert": f"Please return this chemical to {room_number}, {building_name} {space_description or ''}".strip()
                }, 400

            # Chemical matches the room
            print(f"DEBUG: Chemical is in the correct room: {selected_room_id}")
            response_data = {
                "chemical_info": {
                    "id": chemical.id,
                    "name": chemical.name,
                    "cas_number": chemical.cas_number,
                    "barcode": chemical.barcode,
                    "amount": chemical.amount,
                    "unit": chemical.unit,
                    "expiration_date": chemical.expiration_date.strftime('%Y-%m-%d') if chemical.expiration_date else "N/A",
                    "room": f"{room.room_number}, {building_name}",
                    "room_id": chemical.room_id,
                    "space": space_description or "",
                    "space_id": chemical.space_id
                }
            }
            print(f"DEBUG: Returning chemical info: {response_data}")
            return response_data, 200

        except Exception as e:
            print(f"ERROR: Exception occurred - {str(e)}")
            return {"error": f"Internal server error: {str(e)}"}, 500


class PILoginResource(Resource):
    def post(self):
        print("DEBUG: PILoginResource called")
        data = request.get_json()
        email = data.get("email")  # Match LoginResource by using email
        password = data.get("password")
        print("DEBUG: Email received:", email)
        print("DEBUG: Password received:", password)

        # Validate PI credentials
        pi = PI.query.filter_by(email=email).first()  # Use email for PI lookup
        print("DEBUG: Found PI:", pi)
        if pi and pi.check_password(password):
            # Fetch rooms associated with the PI
            rooms = Room.query.filter_by(pi_id=pi.id).all()
            room_data = [
                {
                    "room_id": room.id,
                    "room_number": room.room_number,
                    "building_name": Building.query.get(room.building_id).name  # Correctly fetch building name
                }
                for room in rooms
            ]

            return jsonify({
                "success": True,
                "pi_id": pi.id,  # Include PI id for consistency
                "pi_name": pi.name,  # Use pi.name as the PI's name
                "rooms": room_data  # Associated rooms
            })

        return jsonify({"success": False, "message": "Invalid email or password"}), 401



# --- Login Route ---
class LoginResource(Resource):
    def post(self):
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        # Validate user credentials
        user = User.query.filter_by(email=email).first()
        if user and user.check_password(password):
            # Fetch PIs and associated room/building details
            pi_data = []
            for pi in user.pis:
                rooms = Room.query.filter_by(pi_id=pi.id).all()
                room_data = [
                    {
                        "room_id": room.id,
                        "room_number": room.room_number,
                        "building_name": Building.query.get(room.building_id).name
                    }
                    for room in rooms
                ]
                pi_data.append({
                    "pi_id": pi.id,
                    "pi_name": pi.name,
                    "rooms": room_data
                })

            return jsonify({
                "success": True,
                "user_name": user.name,
                "pis": pi_data
            })

        return jsonify({"success": False, "message": "Invalid email or password"}), 401


# --- Routes for Chemicals ---
class ChemicalListResource(Resource):
    def get(self):
        chemicals = Chemical.query.all()
        return jsonify([{
            'id': chem.id,
            'name': chem.name,
            'barcode': chem.barcode,
            'amount': chem.amount,
            'unit': chem.unit,
            'total_weight_lbs': chem.total_weight_lbs,
            'room': chem.room.room_number if chem.room else None,  # Room information
            'space': chem.space.description if chem.space else None  # Space information
        } for chem in chemicals])

    def post(self):
        data = request.get_json()

        expiration_date = data.get('expiration_date')
        if expiration_date:
            expiration_date = datetime.strptime(expiration_date, '%Y-%m-%d').date()
        
        new_chemical = Chemical(
            name=data['name'],
            cas_number=data['cas_number'],
            room_id=data['room_id'],
            space_id=data.get('space_id'),  # Optional
            amount=data['amount'],
            unit=data['unit'],
            expiration_date=expiration_date,
            total_weight_lbs=data['total_weight_lbs']
        )
        db.session.add(new_chemical)
        db.session.commit()
        return jsonify({'id': new_chemical.id, 'barcode': new_chemical.barcode})

# --- Route to find chemicals by name, barcode, or CAS number ---
class ChemicalQueryResource(Resource):
    def get(self):
        # Extracting query parameters
        name = request.args.get('name')
        barcode = request.args.get('barcode')
        cas_number = request.args.get('cas_number')
        
        query = Chemical.query
        if name:
            query = query.filter_by(name=name)
        if barcode:
            query = query.filter_by(barcode=barcode)
        if cas_number:
            query = query.filter_by(cas_number=cas_number)
        
        chemicals = query.all()
        return jsonify([{
            'id': chem.id,
            'name': chem.name,
            'barcode': chem.barcode,
            'amount': chem.amount,
            'unit': chem.unit,
            'total_weight_lbs': chem.total_weight_lbs,
            'room': chem.room.room_number if chem.room else None,  # Room information
            'space': chem.space.description if chem.space else None  # Space information
        } for chem in chemicals])

# --- Route to find PIs associated with a user ---
class UserPIResource(Resource):
    def get(self, user_id):
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404

        pis = user.pis
        return jsonify([{
            'id': pi.id,
            'name': pi.name,
            'email': pi.email,
            'rooms': [{'id': room.id, 'room_number': room.room_number} for room in pi.rooms]  # PI's rooms
        } for pi in pis])

# --- Route to create Users ---
class UserResource(Resource):
    def post(self):
        data = request.get_json()
        new_user = User(
            name=data['name'],
            email=data['email'],
            password=data['password']
        )
        db.session.add(new_user)
        db.session.commit()
        return jsonify({'id': new_user.id, 'name': new_user.name})
    
# --- Route to associate a PI with a User ---
class UserPIAssociationResource(Resource):
    def post(self, user_id, pi_id):
        user = User.query.get(user_id)
        pi = PI.query.get(pi_id)

        if not user or not pi:
            return jsonify({'error': 'User or PI not found'}), 404

        # Associate PI with the User (many-to-many relationship)
        user.pis.append(pi)
        db.session.commit()

        return jsonify({'message': f'PI {pi.name} associated with User {user.name}'})

    def delete(self, user_id, pi_id):
        user = User.query.get(user_id)
        pi = PI.query.get(pi_id)

        if not user or not pi:
            return jsonify({'error': 'User or PI not found'}), 404

        # Remove association between PI and User
        user.pis.remove(pi)
        db.session.commit()

        return jsonify({'message': f'PI {pi.name} removed from User {user.name}'})

# --- Route to create PIs ---
class PIResource(Resource):
    def post(self):
        data = request.get_json()
        new_pi = PI(
            name=data['name'],
            email=data['email'],
            password=data['password']
        )
        db.session.add(new_pi)
        db.session.commit()
        return jsonify({'id': new_pi.id, 'name': new_pi.name})
    
# --- Route to get all PIs ---
class PIListResource(Resource):
    def get(self):
        pis = PI.query.all()
        return jsonify([{
            'id': pi.id,
            'name': pi.name,
            'email': pi.email,
            'rooms': [{'id': room.id, 'room_number': room.room_number} for room in pi.rooms]
        } for pi in pis])

# --- Route to get all Users ---
class UserListResource(Resource):
    def get(self):
        users = User.query.all()
        return jsonify([{
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'pis': [{'id': pi.id, 'name': pi.name} for pi in user.pis]  # PIs the user is associated with
        } for user in users])


# --- Route to create Buildings ---
class BuildingResource(Resource):
    def post(self):
        data = request.get_json()
        new_building = Building(
            name=data['name']
        )
        db.session.add(new_building)
        db.session.commit()
        return jsonify({'id': new_building.id, 'name': new_building.name})

# --- Route to create Rooms ---
class RoomResource(Resource):
    def post(self):
        data = request.get_json()
        new_room = Room(
            building_id=data['building_id'],
            room_number=data['room_number'],
            pi_id=data['pi_id'],
            contact_name=data.get('contact_name'),  # Optional
            contact_phone=data.get('contact_phone')  # Optional
        )
        db.session.add(new_room)
        db.session.commit()
        return jsonify({'id': new_room.id, 'room_number': new_room.room_number})

# --- Route to create Spaces ---
class SpaceResourceFull(Resource):
    def post(self):
        data = request.get_json()
        new_space = Space(
            room_id=data['room_id'],
            description=data['description'],
            space_type=data.get('space_type'),  # Optional
            space_id=data.get('space_id')  # Optional
        )
        db.session.add(new_space)
        db.session.commit()
        return jsonify({'id': new_space.id, 'description': new_space.description})

class ChemicalsByRoom(Resource):
    """
    RESTful resource to handle retrieving chemicals by room ID.
    """

    def get(self, room_id):
        """
        Retrieve a list of chemicals associated with the given room_id.
        """
        try:
            # Query the database for chemicals with the specified room_id
            chemicals = Chemical.query.filter_by(room_id=room_id).all()

            if not chemicals:
                return {"message": "No chemicals found for the given room ID"}, 404

            # Format the response
            chemical_list = [
                {
                    "room_id": chemical.room_id,
                    "barcode": chemical.barcode,
                    "name": chemical.name
                }
                for chemical in chemicals
            ]

            return {"chemicals": chemical_list}, 200

        except Exception as e:
            return {"error": str(e)}, 500


# --- Add the new routes to your app ---
def initialize_routes(api):
    api.add_resource(AddChemicalResource, '/add_chemical')
    api.add_resource(FetchBuildingsResource, '/buildings-fetch')
    api.add_resource(AddRoomResource, '/add_room')
    api.add_resource(RoomUpdateFieldResource, '/rooms/update_field')
    api.add_resource(ManageSpaceResource, '/manage_space')
    api.add_resource(RoomDetailsResource, '/rooms/details')
    api.add_resource(SearchChemicalsResource, '/search-chemical')
    api.add_resource(ChemicalDelete, '/chemicaldelete/<int:chemical_id>')
    api.add_resource(ChemicalEdit, '/chemicals/update')
    api.add_resource(SpaceResource, '/rooms/<int:room_id>/spaces')
    api.add_resource(CheckChemical, '/scan/check_chemical')
    api.add_resource(PILoginResource, '/pi-login')
    api.add_resource(LoginResource, '/login')
    api.add_resource(ChemicalListResource, '/chemicals')
    api.add_resource(ChemicalQueryResource, '/chemicals/query')
    api.add_resource(UserPIResource, '/users/<int:user_id>/pis')
    api.add_resource(UserResource, '/users')
    api.add_resource(PIResource, '/pis')
    api.add_resource(PIListResource, '/pis/all')  
    api.add_resource(UserListResource, '/users/all')  
    api.add_resource(BuildingResource, '/buildings')
    api.add_resource(RoomResource, '/rooms')
    api.add_resource(SpaceResourceFull, '/spaces')
    api.add_resource(UserPIAssociationResource, '/users/<int:user_id>/pis/<int:pi_id>')
    api.add_resource(ChemicalsByRoom, '/chemicals/room/<int:room_id>')
