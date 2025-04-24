# Focused Rust Learning Roadmap

## phase 1: core rust (2 weeks)
    
### week 1: fundamentals
    ownership & borrowing
        - move semantics (focus: understanding stack/heap)
        - reference rules (focus: single writer XOR multiple readers)
        - basic lifetime annotations (focus: function signatures)
    
    error handling essentials
        - result<t,e> patterns
        - error propagation (?)
        - basic custom errors
    
### week 2: types & traits
    type system essentials
        - structs & enums 
        - impl blocks
        - basic generic types
        - core trait patterns (from, into, display)
    
    async foundations
        - future trait conceptual model
        - async/await syntax
        - tokio runtime basics
        
## phase 2: web & data (2 weeks)

### week 3: actixweb essentials
    server basics
        - routes & handlers
        - request/response lifecycle
        - basic state management
    
    middleware concepts
        - logging setup
        - basic auth patterns
        - error handling middleware
    
### week 4: database integration
    neo4j foundations
        - connection management
        - basic crud operations
        - transaction handling
        - error handling patterns
    
    graph operations
        - node/relationship basics
        - cypher query fundamentals
        - basic graph traversals

## essential exercises
1. ownership
    - implement vector wrapper with clear ownership rules
    - handle string manipulations with borrows
    
2. error handling
    - create custom error type
    - implement error conversion traits
    
3. async
    - concurrent request handler
    - timeout management
    
4. actixweb
    - basic crud api
    - middleware chain
    - stateful handler
    
5. database
    - neo4j connection pool
    - basic graph operations
    - transaction wrapper

## success criteria
- demonstrate ownership understanding through code review
- implement basic actixweb endpoints
- handle neo4j operations safely
- write clean error handling
- understand async fundamentals

## technical scope
- rust 1.75+
- actixweb 4.0+
- neo4j 5.0+
- tokio runtime
