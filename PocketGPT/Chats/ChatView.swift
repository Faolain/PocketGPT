//
//  ChatView.swift
//  PocketGPT
//
//  Created by Limeng Ye on 2024/2/20.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var aiChatModel: AIChatModel
//    @EnvironmentObject var orientationInfo: OrientationInfo
    
    @State var placeholderString: String = "Message"
//    @State private var inputText: String = "Type your message..."
    
    enum FocusedField {
        case firstName, lastName
    }
    
//    @Binding var model_name: String
//    @Binding var chat_selection: Dictionary<String, String>?
    @Binding var chat_title: String?
//    @Binding var title: String
//    var close_chat: () -> Void
//    @Binding var add_chat_dialog:Bool
//    @Binding var edit_chat_dialog:Bool
    @State private var reload_button_icon: String = "arrow.counterclockwise.circle"
    
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    @State private var scrollTarget: Int?
    @State private var toggleEditChat = false
    @State private var clearChatAlert = false

    @FocusState private var focusedField: FocusedField?
    
    @Namespace var bottomID
    
//    @State private var mode = "Chat"
//    let modeList = ["Chat", "Image Creation"]
    
    
    @FocusState
    private var isInputFieldFocused: Bool
    
    func scrollToBottom(with_animation:Bool = false) {
        var scroll_bug = true
#if os(macOS)
        scroll_bug = false
#else
        if #available(iOS 16.4, *){
            scroll_bug = false
        }
#endif
        if scroll_bug {
            return
        }
        let last_msg = aiChatModel.messages.last // try to fixscrolling and  specialized Array._checkSubscript(_:wasNativeTypeChecked:)
        if last_msg != nil && last_msg?.id != nil && scrollProxy != nil{
            if with_animation{
                withAnimation {
                    //                    scrollProxy?.scrollTo(last_msg?.id, anchor: .bottom)
                    scrollProxy?.scrollTo("latest")
                }
            }else{
                //                scrollProxy?.scrollTo(last_msg?.id, anchor: .bottom)
                scrollProxy?.scrollTo("latest")
            }
        }
        
    }
    
    func reload() {
        guard let chat_title else {
            return
        }
//        print(chat_selection)
        print("\nreload\n")
//        aiChatModel.stop_predict()
//        await aiChatModel.prepare(model_name,chat_selection!)
//        aiChatModel.model_name = model_name
//        aiChatModel.chat_name = chat_selection!["chat"] ?? "Not selected"
//        title = chat_selection!["title"] ?? ""
//        aiChatModel.Title = chat_selection!["title"] ?? ""
//        aiChatModel.messages = []
//        aiChatModel.messages = load_chat_history(chat_selection!["chat"]!+".json")!
//        aiChatModel.AI_typing = -Int.random(in: 0..<100000)
//        aiChatModel.chat_name = chat_selection!["title"] ?? "none"
        if chat_title == "Chat" {
            placeholderString = "Message"
        } else if chat_title == "Image Creation" {
            placeholderString = "Describe the image"
        }
        aiChatModel.prepare(chat_title: chat_title/*chat_selection: chat_selection*/)
    }
    
    private func delayIconChange() {
        // Delay of 7.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            reload_button_icon = "arrow.counterclockwise.circle"
        }
    }
    
    private var starOverlay: some View {
        
        Button {
            Task{
                scrollToBottom()
            }
        }
        
    label: {
        Image(systemName: "arrow.down.circle")
            .resizable()
            .foregroundColor(.white)
            .frame(width: 25, height: 25)
            .padding([.bottom, .trailing], 15)
            .opacity(0.4)
    }
    .buttonStyle(BorderlessButtonStyle())
    }
    
    
    
    var body: some View {
        VStack{
//            HStack {
//                Spacer()
//                
//                Text("Current mode:")
//                Picker("Choose mode", selection: $mode) {
//                    ForEach(modeList, id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(.menu)
//                .onChange(of: mode) {
//                    tag in print("Color tag: \(tag)") }
//
//                
//                Spacer()
//            }
            VStack{
//                if aiChatModel.state == .loading{
//                    VStack {
////                        Text("Model loading...")
////                            .padding(.top, 5)
////                            .frame(width: .infinity)
////                            .background(.regularMaterial)
//                        ProgressView(value: aiChatModel.load_progress)
//                    }
//                }
            }
            ScrollViewReader { scrollView in
                VStack {
                    List {
                        ForEach(aiChatModel.messages, id: \.id) { message in
                            MessageView(message: message).id(message.id)
                        }
                        .listRowSeparator(.hidden)
                        Text("").id("latest")
                    }
                    .listStyle(PlainListStyle())
//                    .overlay(starOverlay, alignment: .bottomTrailing)
                }
                .onChange(of: aiChatModel.AI_typing){ ai_typing in
                    scrollToBottom(with_animation: false)
                }
                
                
//                .disabled(chat_selection == nil)
                .onAppear(){
                    scrollProxy = scrollView
                    scrollToBottom(with_animation: false)
                    focusedField = .firstName
                }
            }
            .frame(maxHeight: .infinity)
//            .disabled(aiChatModel.state == .loading)
            .onChange(of: chat_title/*chat_selection*/) { chat_name in
                Task {
//                    if chat_name == nil{
//                        close_chat()
//                    }
//                    else{
                        //                    isInputFieldFocused = true
                        self.reload()
//                    }
                }
            }
            .toolbar {
                Button {
                    Task {
                        clearChatAlert = true
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .alert("Conversation history will be deleted", isPresented: $clearChatAlert, actions: {
                    Button("Cancel", role: .cancel, action: {})
                    Button("Proceed", role: .destructive, action: {
                        aiChatModel.messages = []
                        // save_chat_history(aiChatModel.messages,aiChatModel.chat_name)
//                        clear_chat_history(aiChatModel.messages, aiChatModel.chat_name)
                        clear_chat_history(aiChatModel.chat_name)
                    })
                }, message: {
//                    Text("The message history will be cleared")
                })
//                Button {
//                    Task {
////                        self.aiChatModel.chat = nil
//                        reload_button_icon = "checkmark"
//                        delayIconChange()
//                    }
//                } label: {
//                    Image(systemName: reload_button_icon)
//                }
////                .disabled(aiChatModel.predicting)
//                //                .font(.title2)
//                Button {
//                    Task {
//                                            //    add_chat_dialog = true
//                        toggleEditChat = true
//                        edit_chat_dialog = true
//                        //                        chat_selection = nil
//                    }
//                } label: {
//                    Image(systemName: "slider.horizontal.3")
//                }
                //                .font(.title2)
            }
//            .navigationTitle(aiChatModel.Title)
            
            LLMTextInput(messagePlaceholder: placeholderString).environmentObject(aiChatModel)
            .focused($focusedField, equals: .firstName)
            
        }
//        .sheet(isPresented: $toggleEditChat) {
//            AddChatView(add_chat_dialog: $toggleEditChat,
//                        edit_chat_dialog: $edit_chat_dialog,
//                        chat_name: aiChatModel.chat_name,
//                        renew_chat_list: .constant({}))/*.environmentObject(aiChatModel)*/
//#if os(macOS)
//                .frame(minWidth: 400,minHeight: 600)
//#endif
//        }
    }
}

//#Preview {
//    ChatView()
//}